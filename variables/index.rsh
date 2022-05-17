'reach 0.1';

// In Reach, only constants are used throughout the program. Even though this
// might seem like a limitation it is possible to do any iterative operation
// with constants using map, reduce and forEach

// There's one exception to this rule and it is var usage in while loops.

/*
  For example a Javascript code like this

  const arr = [1,2,3,4]
  let sum = 0
  for (const item of array) {
    sum += item;
  } 

  translates to this Reach code:

  const arr = array(UInt, [1,2,3,4]);
  const sum = array.reduce(0, (prev, val) => prev + val);
*/

// You can define constants outside the application
const MAX_UINT = UInt.max;

// You can define pure functions outside the application
const timesTwo = x => x * 2

// Functions are inlined in the application so you can make only calls and
// consensus operations within a function. You just have to pass participant
const log = (participant, msg) => {
  participant.interact.log(msg);
}

export const main = Reach.App(() => {
  const Deployer = Participant('Deployer', {
    log: Fun(true, Null),
    getUInt: Fun([], UInt)
  });

  init();

  Deployer.only(() => {
    // A constant can have three visibilities
    // - Private: Only current caller can access these values
    // - Local Public: It is ready to be published to the network
    // - Public: Everyone can access this values 

    // Results of participant calls are always private.
    const _privateValue = interact.getUInt();

    // Literal constants are public, as anyone reading the code would know it
    const publicLiteral = 5;

    // In order to make a private constant public, you have to 'publish' it to 
    // the blockchain. To publish a constant you have to 'declassify' it
    const localPublicValue = declassify(_privateValue);
  });

  Deployer.publish(localPublicValue);
  log(Deployer, "Deployed the contract");

  // This will error in compile-time
  // const impossible = _privateValue;

  // After the publish() call you can access all published values and declare
  // new constants
  const myUInt = localPublicValue;
  const myObject = {
    caller: this,
    currentTime: thisConsensusTime()
  }

  // While loops are exception to const rule, as loop variable changes during
  // the loop
  var loopVariable = 0;
  invariant(balance() == 0);
  while (loopVariable < 100) {
    commit();

    Deployer.only(() => {
      const incrementAmt = declassify(interact.getUInt());
    })
    Deployer.publish(incrementAmt);

    loopVariable = loopVariable + incrementAmt;
    continue;
  }

  // Parallel reduce is a syntactic sugar of a certain while loop, so even 
  // though technically we declare the loop variables are defined constant
  // it is mutated after each parallelReduce loop
  const prLoopVariable = parallelReduce(0)
    .invariant(balance() == 0)
    .while(loopVariable < 100)
    .case(
      Deployer,
      (() => ({
        msg: declassify(interact.getUInt())
      })),
      ((incrementAmt) => {
        return loopVariable + incrementAmt;
      })
    )
    .timeout(false);

  commit();
  exit();
});
