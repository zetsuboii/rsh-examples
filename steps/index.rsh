'reach 0.1';

// Steps are a key concept of Reach. It allows us to handle the behaviour on 
// the blockchain and the front-end at the same time.

// In the simplest way a Reach program consists of blockchain interactions and
// commits. A blockchain interaction specifies which participant is going to 
// call function and commit() tells that interaction is finished.

/*
  /////////////////////////////////////
  //   HAPPENS ON ALICE'S COMPUTER   //  
  //          (local step)           //  
  /////////////////////////////////////

  Alice.publish();

  ////////////////////////////////////
  //      HAPPENS ON BLOCKCHAIN     //
  //        (consensus step)        //  
  ////////////////////////////////////

  commit();

  /////////////////////////////////////
  //   HAPPENS ON ALICE'S COMPUTER   //  
  //          (local step)           //  
  /////////////////////////////////////
*/

// Everything between a blokchain interaction and commit() happens on that
// participant's transaction and is saved to the blockchain.

/*
  Alice.publish();              <- Alice is going to interact with blockchain 
  const x = 5;                  <- Happens in Alice's transaction
  const y = 5 * 10;             <- Happens in Alice's transaction
  transfer(balance()).to(Bob);  <- Happens in Alice's transaction

  commit();

  Bob.publish();                <- Bob is going to interact with blockchain
  const z = x * y;              <- Happens in Bob's transaction

  commit();
*/

// There are 2 ways to interact with blockchain
// - publish: Publishes a value to the blockchain,
//   can be called empty ( Alice.publish() )
// - pay: Pays some amount to the contract

// publish and pay can be chained to publish and pay at the same time

// Publishes and commits are enough to write valid Reach programs
export const minimal = Reach.App(() => {
  const A = Participant('A', {});
  const B = Participant('B', {});
  init();

  A.publish();
  commit();

  B.publish();
  commit();

  exit();
});

// In order to have meaningful programs, we ask users (participants) for inputs
// through the program. This means user runs a computation on their machine and 
// send the result of it to the blockchain. This is done in an .only block
// An only block happens on participant's machine and only the values user
// 'publishes' are sent to the blockchain

// In order to publish to the blockchain, .only() has to be after commit() and 
// before publish() & value to be published must be local public (declassified)

export const payment = Reach.App(() => {
  const A = Participant('A', {
    getPayAmount: Fun([], UInt)
  });
  const B = Participant('B', {});
  init();

  A.only(() => {
    const payAmount = declassify(interact.getPayAmount());
  })
  A.publish(payAmount).pay(payAmount);
  commit();

  B.publish();
  transfer(payAmount).to(B);

  commit();
  exit();
});

// Some functions require you to be on consensus step. Some of them are
// - loops
// - constant declarations (const x = 5)
// - transfer()
// In order to call them, you have to either publish or pay

export const consensus = Reach.App(() => {
  const A = Participant('A', {
    increment: Fun([], Null)
  });
  init();

  // parallelReduce is a consensus step operation, have to publish
  A.publish();

  const val = parallelReduce(0)
    .invariant(balance() == 0)
    .while(true)
    .case(
      A,
      (() => ({ when: true })),
      ((_) => {
        A.interact.increment();
        return val + 1;
      }))
    .timeout(1024, () => {
      Anybody.publish();
      return val;
    });

  commit();

  // transfer is also a consensus operation, in order to transition to consensus
  // step we used pay()
  A.pay(100);
  transfer(100).to(A);
  commit();
  
  exit();
});