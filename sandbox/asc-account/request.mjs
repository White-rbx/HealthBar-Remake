// Account QA request validation, isolated from legacy Ban API dependencies.
// Keep failures structured and never include request payloads in public errors.
export class BanError extends Error {
 constructor(status,code,message){super(message);this.status=status;this.code=code;}
}
function fail(status,code,message){throw new BanError(status,code,message)}
export async function readJson(request,maxBytes=24000){
 if(!/^application\/json(?:\s*;\s*charset=utf-8)?$/i.test(request.headers.get('Content-Type')??''))
  fail(415,'content_type','Expected application/json.');
 if(!request.body || Number(request.headers.get('Content-Length'))>maxBytes)
  fail(413,'body_size','Request is too large.');
 const reader=request.body.getReader();
 const chunks=[];
 let count=0;
 try{
  while(true){
   const {done,value}=await reader.read();
   if(done)break;
   count+=value.length;
   if(count>maxBytes){await reader.cancel();fail(413,'body_size','Request is too large.');}
   chunks.push(value);
  }
 }finally{reader.releaseLock();}
 const bytes=new Uint8Array(count);
 let offset=0;
 for(const chunk of chunks){bytes.set(chunk,offset);offset+=chunk.length;}
 try{return JSON.parse(new TextDecoder('utf-8',{fatal:true}).decode(bytes))}
 catch{fail(400,'invalid_request','Invalid request fields or values.')}
}
