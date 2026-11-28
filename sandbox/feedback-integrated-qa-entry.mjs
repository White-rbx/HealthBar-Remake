// Import ONLY the complete privately built Candidate (never expose it as the public main module).
// This synthetic-only QA entry is deployed to an isolated, disposable Worker with dummy secrets.
import candidate from './candidate.mjs';
const reply=(data,status=200)=>new Response(JSON.stringify(data),{status,headers:{'Content-Type':'application/json','Cache-Control':'no-store','X-Robots-Tag':'noindex'}});
export default {async fetch(incoming,env,ctx) {
  if(incoming.method!=='POST'||new URL(incoming.url).pathname!=='/__qa/once')
    return reply({ok:false},404);
  if(!env.DB||!env.ARCSCRIPT_ADMIN_KEY||!env.ASC_FEEDBACK_RATE_SECRET)
    return reply({ok:false,phase:'bindings'},503);
  const lock=await env.DB.prepare(
    'INSERT INTO asc_feedback_rate_windows(scope_hash,window_start,hits,expires_unix) VALUES(?,0,1,2147483647) ON CONFLICT DO NOTHING RETURNING hits'
  ).bind('x'.repeat(43)).first();
  if(!lock)return reply({ok:false,phase:'already-run'},409);
  async function run(path,method,data,headers={}) {
    // Synthetic only: the base URL is a local Request object, not a network fetch to Production.
    const req=new Request('https://arcscriptcenter-api.kogpasan14.workers.dev'+path,{
      method,headers:{...(method==='POST'?{'Content-Type':'application/json'}:{}),'CF-Connecting-IP':'198.51.100.20',...headers},
      ...(method==='POST'?{body:JSON.stringify(data||{})}:{})
    });
    Object.defineProperty(req,'cf',{configurable:true,value:{tlsVersion:'TLSv1.3'}});
    const result=await candidate.fetch(req,env,ctx);
    let value={};try{value=await result.json()}catch{}
    return {code:result.status,value};
  }
  const st={};let caseId='';
  try {
    st.legacyBootstrap=(await run('/api/v1/client/bootstrap','GET')).code;
    st.adminWithoutKey=(await run('/api/v1/admin/feedback/list','GET')).code;
    st.adminWrongOrigin=(await run('/api/v1/admin/feedback/list','GET',null,{'X-Admin-Key':env.ARCSCRIPT_ADMIN_KEY,Origin:'https://untrusted.invalid'})).code;
    st.invalidFeedback=(await run('/api/v1/feedback/submit','POST',{kind:'feedback',topic:'x',description:'too short'})).code;
    const submitted=await run('/api/v1/feedback/submit','POST',{
      kind:'feedback',topic:'Synthetic QA',
      description:'This is a synthetic request for isolated production candidate integration testing only.'
    });
    st.submitted=submitted.code;
    if(submitted.code!==201||!submitted.value?.id||!submitted.value?.receipt)
      return reply({ok:false,phase:'submit',statuses:st},500);
    caseId=submitted.value.id;const receipt=submitted.value.receipt;
    st.wrongReceipt=(await run('/api/v1/feedback/status','POST',{id:caseId,receipt:'0'.repeat(64)})).code;
    const before=await run('/api/v1/feedback/status','POST',{id:caseId,receipt});
    st.validReceipt=before.code;
    st.privateNoteHidden=before.value?.case?.admin_note===undefined&&before.value?.case?.adminNote===undefined;
    st.userEdited=(await run('/api/v1/feedback/manage','POST',{
      id:caseId,receipt,operation:'edit',topic:'Synthetic QA Edited',
      description:'This updated synthetic request verifies the editable reviewing state safely.'
    })).code;
    const admin={'X-Admin-Key':env.ARCSCRIPT_ADMIN_KEY,Origin:'https://arcscriptcenter-dashboard.pages.dev'};
    st.adminList=(await run('/api/v1/admin/feedback/list','GET',null,admin)).code;
    st.adminReview=(await run('/api/v1/admin/feedback','POST',{
      id:caseId,status:'approved',publicNote:'Synthetic public response',adminNote:'Synthetic internal note'
    },admin)).code;
    const finalStatus=await run('/api/v1/feedback/status','POST',{id:caseId,receipt});
    st.finalStatus=finalStatus.code;
    st.approved=finalStatus.value?.case?.status==='approved';
    st.privateNoteStillHidden=finalStatus.value?.case?.admin_note===undefined&&finalStatus.value?.case?.adminNote===undefined;
    st.editAfterReview=(await run('/api/v1/feedback/manage','POST',{
      id:caseId,receipt,operation:'edit',topic:'Forbidden edit',
      description:'This edited request must be blocked when its case has already been reviewed.'
    })).code;
    const expected={legacyBootstrap:200,adminWithoutKey:401,adminWrongOrigin:403,
      invalidFeedback:400,submitted:201,wrongReceipt:404,validReceipt:200,
      privateNoteHidden:true,userEdited:200,adminList:200,adminReview:200,
      finalStatus:200,approved:true,privateNoteStillHidden:true,editAfterReview:409};
    const failing=Object.keys(expected).filter(key=>st[key]!==expected[key]);
    return reply({ok:failing.length===0,statuses:st,failedKeys:failing,source:'real-candidate-isolated-d1'},failing.length?500:200);
  } catch(e) {
    // No receipt, note, user data or admin secret in the response.
    return reply({ok:false,phase:'runtime-exception',statuses:st,errorType:String(e?.name||'Error').slice(0,40)},500);
  }
}};
