import {createHash} from 'node:crypto';

const PINNED_BAN_JS_SHA='10fd3258a0d38faaa16ebc0d14124e567f687dde76050042e8a5ff141c9cb8fd';
const SCRIPT=/^const BAN_MODE_SCRIPT = ("(?:[^"\\]|\\.)*");$/m;

export function buildBanV2PagesWorker(originalWorker,liveAddon,nextAddon,{stagingGitHub=false}={}) {
 const hash=createHash('sha256').update(liveAddon).digest('hex');
 if(hash!==PINNED_BAN_JS_SHA)throw new Error('Live Ban Center addon changed. Review the new source first.');
 const match=originalWorker.match(SCRIPT);
 if(!match||typeof nextAddon!=='string'||!nextAddon.includes('/api/v1/admin/bans/v2/manage'))
  throw new Error('Unsupported Pages layout.');
 const expected=JSON.parse(match[1]);
 if(expected!==liveAddon)throw new Error('Repo addon differs from the pinned live Preview.');
 for(const marker of ['MOD_SCRIPT','id="page-bans"','env.ASSETS.fetch','/__asc1650/ban-mode.js'])
  if(!originalWorker.includes(marker))throw new Error('Missing original Pages route: '+marker);
 const scope='const stagingGitHub=false;';
 if(nextAddon.split(scope).length!==2)throw new Error('Unexpected dashboard scope control.');
 const configured=stagingGitHub?nextAddon.replace(scope,'const stagingGitHub=true;'):nextAddon;
 return originalWorker.replace(SCRIPT,()=> 'const BAN_MODE_SCRIPT = '+JSON.stringify(configured)+';');
}
