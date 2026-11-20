// Dedicated synthetic QA. No service bindings to the active or production APIs.
import {mountBanV2} from './ban-v2-integration-worker.mjs';

export default mountBanV2({
  fetch: () => new Response('Not found', {status: 404}),
}, {
  adminAuthenticated: async () => false,
  bannedTokens: true,
});
