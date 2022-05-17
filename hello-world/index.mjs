import {loadStdlib} from '@reach-sh/stdlib';
import * as backend from './build/index.main.mjs';
const stdlib = loadStdlib(process.env);

const startingBalance = stdlib.parseCurrency(100);
const aliceAccount = await stdlib.newTestAccount(startingBalance);
const aliceContract = aliceAccount.contract(backend);

await Promise.all([
  aliceContract.participants.Alice({
    see: (...messages) => {
      console.log(...messages);
    }
  })
]);
