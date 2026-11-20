import {BanError,gitBlobSha} from './ban-v2-integration.mjs';

const unavailable=()=>{throw new BanError(503,'source_unavailable','Ban source unavailable. Load the list before retrying.');};
const BASE64=/^[A-Za-z0-9+/=\s]+$/;
const FIXED_GITHUB_API='https://api.github.com/repos/White-rbx/HealthBar-Remake/contents/sandbox/banned-check-center-source-STAGING.lua';
const FIXED_GITHUB_BRANCH='banned-check-center-staging-data';
const requestHeaders=token=>({Authorization:'Bearer '+token,Accept:'application/vnd.github+json',
 'User-Agent':'ArcScriptCenter-Staging-Ban-Center','X-GitHub-Api-Version':'2022-11-28'});

function toBase64(text) {
 const bytes=new TextEncoder().encode(text);
 let binary='';
 for(let i=0;i<bytes.length;i+=8192)binary+=String.fromCharCode(...bytes.subarray(i,i+8192));
 return btoa(binary);
}

export function createStagingGitHubBanStore(fetcher=fetch) {
 function headers(env) {
  if(typeof env.GITHUB_TOKEN!=='string'||env.GITHUB_TOKEN.length<30)unavailable();
  return requestHeaders(env.GITHUB_TOKEN);
 }
 return {
  label:'staging-github',
  async read(env){
   const url=FIXED_GITHUB_API+'?ref='+FIXED_GITHUB_BRANCH;
   const r=await fetcher(url,{headers:headers(env),cache:'no-store',redirect:'error'});
   if(!r.ok)unavailable();
   const v=await r.json();
   if(v.type!=='file'||v.encoding!=='base64'||typeof v.content!=='string'||v.content.length>540000||!BASE64.test(v.content))unavailable();
   const source=new TextDecoder('utf-8',{fatal:true}).decode(Uint8Array.from(atob(v.content),letter=>letter.charCodeAt(0)));
   if(await gitBlobSha(source)!==v.sha)unavailable();
   return {sha:v.sha,source};
  },
  async write(env,{source,expectedSha,action,target,now}){
   if(env.BAN_MANAGEMENT_WRITE!=='staging-github')unavailable();
   const sha=await gitBlobSha(source);
   const id=crypto.randomUUID();
   const authHeaders=headers(env);
   await env.DB.prepare(`INSERT INTO asc_ban_v2_audit
    (request_id,action,target_user_id,old_sha,new_sha,created_unix,outcome)
    VALUES(?,?,?,?,?,?,'pending')`).bind(id,action,target,expectedSha,sha,now).run();
   let commitSha=null,outcome='unconfirmed';
   try{
    const response=await fetcher(FIXED_GITHUB_API,{
     method:'PUT',headers:{...authHeaders,'Content-Type':'application/json'},redirect:'error',
     body:JSON.stringify({branch:FIXED_GITHUB_BRANCH,sha:expectedSha,content:toBase64(source),
      message:'ArcScriptCenter STAGING: '+action+' Ban record'}),
    });
    if(response.status===409||response.status===422)outcome='conflict';
    else if(response.ok){
     const payload=await response.json();
     if(payload.content?.sha===sha&&/^[a-f0-9]{40}$/.test(payload.commit?.sha)){
      outcome='saved';
      commitSha=payload.commit.sha;
     }
    }else outcome='rejected';
   }catch{
    // A lost response cannot establish whether GitHub committed the update.
   }
   let auditLogged=true;
   try{
    const audit=await env.DB.prepare('UPDATE asc_ban_v2_audit SET outcome=?, commit_sha=? WHERE request_id=?')
     .bind(outcome,commitSha,id).run();
    auditLogged=audit.meta?.changes===1;
   }catch{auditLogged=false;}
   if(outcome==='conflict')return null;
   if(outcome==='saved')return {sha,commitSha,auditLogged};
   if(outcome==='unconfirmed')throw new BanError(503,'write_unconfirmed','GitHub outcome unconfirmed. Load the list before retrying.');
   unavailable();
  },
 };
}

export const d1BanQaStore={
 label:'isolated-qa',
 async read(env) {
  const row=await env.DB.prepare('SELECT sha, source FROM asc_ban_v2_qa_source WHERE id=1').first();
  if(!row||await gitBlobSha(row.source)!==row.sha)unavailable();
  return row;
 },
 async write(env,{source,expectedSha,action,target,now}) {
  const sha=await gitBlobSha(source);
  const result=await env.DB.prepare(`UPDATE asc_ban_v2_qa_source SET source=?,sha=?,action=?,
   target_user_id=?,changed_unix=?,request_id=? WHERE id=1 AND sha=? RETURNING sha`)
   .bind(source,sha,action,target,now,crypto.randomUUID(),expectedSha).first();
  return result?.sha===sha?{sha,auditLogged:true}:null;
 },
};
