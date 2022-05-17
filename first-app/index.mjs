import * as backend from './build/index.main.mjs';
import { loadStdlib, util } from '@reach-sh/stdlib';
const { thread, Signal } = util;

const stdlib = loadStdlib(process.env);

const startingBalance = stdlib.parseCurrency(100);

const [ 
  deployerAccount, 
  userAccount1, 
  userAccount2 
] = await stdlib.newTestAccounts(3, startingBalance);

const deployerContract = deployerAccount.contract(backend);
const userContract1 = userAccount1.contract(backend, deployerContract.getInfo());
const userContract2 = userAccount2.contract(backend, deployerContract.getInfo());

// In order to interact with APIs we have to wait for contract to be deployed
// Signal allows us to handle this. Use await ready.wait() to wait deployment
// and ready.notify() to notify deployment
const ready = new Signal();

// If we want to wait for user 1, we have to use an another Signal
const user1Signal = new Signal();
const user2Signal = new Signal();

const callApi1 = async () => {
  // Wait for deployer to deploy contracts
  await ready.wait();

  // UInts are BigNumber in javascript
  let [ _someOrNone, count ] = await userContract1.views.get();
  console.log(`User 1 saw count: ${count}`);

  // Increment 5
  await userContract1.apis.inc(5);

  user1Signal.notify();
}

const callApi2 = async () => {
  // Wait for deployer to deploy contracts
  await user1Signal.wait();

  // UInts are BigNumber in javascript
  let [ _someOrNone, count ] = await userContract2.views.get();
  console.log(`User 2 saw count: ${count}`);

  // Decrementing more than count will error
  try {
    await userContract2.apis.dec(15);
  }
  catch (e) {
    console.log("Decremented too much");
    // console.log(e);
  }

  // Decrement 3
  await userContract2.apis.dec(3);

  [ _someOrNone, count ] = await userContract2.views.get();
  console.log(`User 2 saw new count: ${count}`);

  user2Signal.notify();
}

const close = async () => {
  await user2Signal.wait();
  process.exit(0);
}

await Promise.all([
  deployerContract.participants.Deployer({
    deployed: () => {
      console.log('Contract is deployed');
      // Notify deployment
      ready.notify();
    }
  }),
  
  thread(callApi1),
  thread(callApi2),
  thread(close)
]);
