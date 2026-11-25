// The independent staging Worker uses the provisioning handler until the
// operator enables the Passkey rollout. It never serves password-based login.
import locked, {EDGE_QA_ORIGIN} from './eslogin-independent-edge-qa.mjs';
import {createAccountWorker} from './worker.mjs';

export const ISOLATED_ESLOGIN_ORIGIN = EDGE_QA_ORIGIN;

export function createIsolatedESLoginCandidate() {
 const accounts = createAccountWorker({origin: EDGE_QA_ORIGIN});
 return {
  fetch(request, env) {
   if (env.ASC_ACCOUNT_MODE !== 'isolated-qa' ||
       env.ASC_ACCOUNT_AUTH_MODE !== 'passkey' ||
       env.ASC_ACCOUNT_LAUNCH_STATE !== 'isolated-test-enabled') {
    return locked.fetch(request);
   }
   return accounts.fetch(request, env);
  },
 };
}

export default createIsolatedESLoginCandidate();
