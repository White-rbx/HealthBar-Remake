// REVIEW ONLY — potential future authenticated QA Worker entry.
// There is deliberately NO default export and NO deployment action.
// This is NOT the current independent edge Worker, which remains provisioning-only.
// The explicit origin pins WebAuthn RP ID and API request-origin verification.
import {createAccountWorker} from './worker.mjs';

export const ISOLATED_ESLOGIN_ORIGIN=
 'https://arcscriptcenter-eslogin-edge-qa.kogpasan14.workers.dev';

export function createIsolatedESLoginCandidate(){
 return createAccountWorker({origin:ISOLATED_ESLOGIN_ORIGIN});
}
