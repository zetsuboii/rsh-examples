import {loadStdlib} from '@reach-sh/stdlib';
import * as backend from './build/index.main.mjs';
const stdlib = loadStdlib(process.env);

const startingBalance = stdlib.parseCurrency(100);

const payer = {}
payer.account = await stdlib.newTestAccount(startingBalance);
payer.contract = await payer.account.contract(backend);
payer.app = payer.contract.participants.Payer;

await Promise.all([
  payer.app({
    
  }),
]);

console.log('Exiting the suite');
