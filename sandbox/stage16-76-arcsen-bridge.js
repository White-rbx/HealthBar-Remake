"use strict";
(() => {
  const $ = id => document.getElementById(id);
  const kind=$("kind"), topic=$("topic"), description=$("description"), userId=$("user-id");
  const submit=$("submit"), message=$("message"), challenge=$("challenge");
  const sitekey="0x4AAAAAAGCDj9GkRoOQYbsL"; // Public real-token Sandbox widget sitekey; never a secret.
  const uuid=/^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;
  const receiptRegex=/^[0-9a-f]{64}$/i;
  const userid=/^[1-9][0-9]{0,15}$/;
  let widget=null,token=null,pending=false,loadedCase=null,challengeGeneration=0;
  let clientKey=null;
  const status=(txt,error=false)=>{
    message.textContent=String(txt);
    message.dataset.error=String(error);
  };
  const unicodeCount=s=>Array.from(String(s)).length;
  const randomHex=()=>{
    const bytes=new Uint8Array(32);
    crypto.getRandomValues(bytes);
    return Array.from(bytes,x=>x.toString(16).padStart(2,"0")).join("");
  };
  function quotaKey(){
    if(clientKey)return clientKey;
    try{
      const stored=sessionStorage.getItem("asc-feedback-anon-v1");
      if(stored&&receiptRegex.test(stored)){clientKey=stored;return clientKey}
    }catch{}
    clientKey=randomHex();
    try{sessionStorage.setItem("asc-feedback-anon-v1",clientKey)}catch{}
    return clientKey;
  }
  function setBusy(value){
    pending=value;
    const ready=typeof token==="string"&&token.length>3;
    submit.disabled=value||!ready;
    $("check-status").disabled=value;
    $("edit-case").disabled=value||!loadedCase?.canManage;
    $("remove-case").disabled=value||!loadedCase?.canManage;
    kind.disabled=value;
  }
  function resetChallenge(){
    token=null;
    submit.disabled=true;
    if(widget!==null && window.turnstile){
      try{window.turnstile.reset(widget)}catch{status("Please reload the page to verify again.",true)}
    }
  }
  function renderChallenge(){
    // Late callbacks from a removed Turnstile widget must never enable Submit.
    const generation=++challengeGeneration;
    token=null;
    submit.disabled=true;
    if(!window.turnstile){status("Could not load Turnstile. Check your connection.",true);return}
    if(widget!==null){try{window.turnstile.remove(widget)}catch{} widget=null}
    challenge.replaceChildren();
    widget=window.turnstile.render(challenge,{
      sitekey,
      action:kind.value==="appeal"?"appeal_submit":"feedback_submit",
      theme:"dark",
      callback:t=>{if(generation!==challengeGeneration)return;token=t;setBusy(pending);status("Verification complete. Review your request before submitting.")},
      "expired-callback":()=>{if(generation!==challengeGeneration)return;token=null;submit.disabled=true;status("Verification expired. Please verify again.",true)},
      "timeout-callback":()=>{if(generation!==challengeGeneration)return;token=null;submit.disabled=true;status("Verification timed out. Please try again.",true)},
      "error-callback":()=>{if(generation!==challengeGeneration)return true;token=null;submit.disabled=true;status("Turnstile error. Please try again.",true);return true}
    });
    status("Complete Turnstile verification before submitting.");
  }
  function switchKind(){
    const appeal=kind.value==="appeal";
    $("userid-group").hidden=!appeal;
    $("length-hint").textContent=appeal?"(50–5000 characters)":"(50–1500 characters)";
    renderChallenge();
  }
  async function post(path,data){
    const ctrl=new AbortController();
    const timeout=setTimeout(()=>ctrl.abort(),20000);
    try{
      const response=await fetch(path,{
        method:"POST",mode:"same-origin",credentials:"same-origin",cache:"no-store",
        headers:{"Content-Type":"application/json","Accept":"application/json"},
        body:JSON.stringify(data),signal:ctrl.signal
      });
      const body=await response.json().catch(()=>({ok:false,error:"Unexpected server response"}));
      if(!response.ok||body.ok!==true)throw Error(body.error||("HTTP "+response.status));
      return body;
    }finally{clearTimeout(timeout)}
  }
  function validateCaseFields(k){
    const t=topic.value.trim(),d=description.value.trim();
    const max=k==="appeal"?5000:k==="feedback"?1500:0;
    if(!max)throw Error("Invalid request type.");
    if(unicodeCount(t)<3||unicodeCount(t)>50)throw Error("Topic must be 3–50 characters.");
    if(unicodeCount(d)<50||unicodeCount(d)>max)throw Error("Description must be 50–"+max+" characters");
    return {kind:k,topic:t,description:d};
  }
  function validateForm(){
    const data=validateCaseFields(kind.value);
    // Claimed Roblox UserId is required only for NEW appeals.
    // The receipt-scoped manage API intentionally never returns the claim.
    if(data.kind==="appeal"&&(!userid.test(userId.value)||!Number.isSafeInteger(Number(userId.value))))
      throw Error("An appeal requires a valid Roblox UserId.");
    return {...data,claimedUserId:data.kind==="appeal"?userId.value.trim():undefined};
  }
  $("request-form").addEventListener("submit",async event=>{
    event.preventDefault();
    if(pending)return;
    if(!token){status("Complete Turnstile verification.",true);return}
    let data;
    try{data=validateForm()}catch(e){status(e.message,true);return}
    // Explicit user confirmation: creates a real row in isolated Sandbox D1.
    if(!confirm("Submit a synthetic test request to Sandbox D1? Save your receipt to remove the test case afterward."))return;
    // Single-use real Turnstile token is never logged, persisted or placed in URL.
    const oneTimeToken=token;
    token=null;
    setBusy(true);
    try{
      const out=await post("/__stage1667/submit",{...data,clientKey:quotaKey(),turnstileToken:oneTimeToken});
      $("created-id").value=out.id;
      $("created-receipt").value=out.receipt;
      $("receipt-section").hidden=false;
      $("lookup-id").value=out.id;
      $("lookup-receipt").value=out.receipt;
      loadedCase=null;
      $("case-section").hidden=true;
      status("Request submitted. Keep your Case ID and Receipt private.");
    }catch(e){
      status("Submission failed: "+e.message+" — Complete a new Turnstile challenge before retrying.",true);
    }finally{setBusy(false);resetChallenge()}
  });
  $("copy-receipt").addEventListener("click",async()=>{
    const id=$("created-id").value,receipt=$("created-receipt").value;
    if(!uuid.test(id)||!receiptRegex.test(receipt))return;
    try{
      await navigator.clipboard.writeText("Case ID: "+id+"\nReceipt: "+receipt);
      status("Copied. Keep your Receipt private.");
    }catch{status("Copy failed. You can select the text manually.",true)}
  });
  function keyData(){
    const id=$("lookup-id").value.trim(),receipt=$("lookup-receipt").value.trim();
    if(!uuid.test(id)||!receiptRegex.test(receipt))throw Error("Enter a valid Case ID and Receipt.");
    return {id,receipt};
  }
  $("check-status").addEventListener("click",async()=>{
    if(pending)return;
    let key;try{key=keyData()}catch(e){status(e.message,true);return}
    setBusy(true);
    try{
      const data=await post("/api/v1/feedback/status",key);
      const c=data.case;
      loadedCase=c;
      $("case-summary").textContent="Status: "+c.status+"\nType: "+c.kind+"\nTopic: "+c.topic+
        "\nDescription: "+c.description+"\nRevisions: "+c.revision+""+
        (c.publicNote?"\nPublic note: "+c.publicNote:"");
      $("case-section").hidden=false;
      kind.value=c.kind;
      // A receipt lookup never returns claimed identity; do not keep a previous
      // new-appeal UserId silently associated with this unrelated case.
      userId.value="900000000000001";
      $("userid-group").hidden=c.kind!=="appeal";
      $("length-hint").textContent=c.kind==="appeal"?"(50–5000 characters)":"(50–1500 characters)";
      topic.value=c.topic;
      description.value=c.description;
      renderChallenge();
      status("Status loaded. Edit the topic or description in the form above.");
    }catch(e){loadedCase=null;$("case-section").hidden=true;status("Status lookup failed: "+e.message,true)}
    finally{setBusy(false)}
  });
  $("edit-case").addEventListener("click",async()=>{
    if(pending||!loadedCase?.canManage)return;
    let key,body;
    try{
      key=keyData();
      if(kind.value!==loadedCase.kind)throw Error("The request type cannot be changed.");
      // Existing appeal edits are receipt-authorized. Re-entering a Roblox
      // UserId would be unnecessary and may leak more identity information.
      body=validateCaseFields(loadedCase.kind);
    }catch(e){status(e.message,true);return}
    if(!confirm("Save the changes from the form above?"))return;
    setBusy(true);
    try{
      await post("/api/v1/feedback/manage",{...key,operation:"edit",topic:body.topic,description:body.description});
      loadedCase.canManage=false;$("case-section").hidden=true;
      status("Updated. Check the status again to refresh the case.");
    }catch(e){status("Update failed: "+e.message,true)}
    finally{setBusy(false)}
  });
  $("remove-case").addEventListener("click",async()=>{
    if(pending||!loadedCase?.canManage)return;
    let key;try{key=keyData()}catch(e){status(e.message,true);return}
    if(!confirm("Remove this request? You will no longer be able to access it using the Receipt."))return;
    setBusy(true);
    try{
      await post("/api/v1/feedback/manage",{...key,operation:"remove"});
      const removedCaseId=key.id;
      loadedCase=null;$("case-section").hidden=true;
      $("case-summary").textContent="";
      $("lookup-receipt").value="";
      if($("created-id").value===removedCaseId){
        $("created-receipt").value="";
        $("created-id").value="";
        $("receipt-section").hidden=true;
      }
      status("Request removed.");
    }catch(e){status("Removal failed: "+e.message,true)}
    finally{setBusy(false)}
  });
  kind.addEventListener("change",switchKind);
  window.addEventListener("load",switchKind,{once:true});
})();
