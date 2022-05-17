'reach 0.1';

export const main = Reach.App(() => {
  // Contract initialization

  const Alice = Participant('Alice', { 
    // Fun defines a function for Alice participant. 
    // Fun([UInt], Bool) is a function that takes an UInt and returns Bool. 
    // Fun(true, Null) is a function that takes any number of arguments and 
    // returns Null (nothing) 
    see: Fun(true, Null) 
  });

  // init() finishes initialization. After this part we can use partipants and
  // their interfaces
  init();

  // publish() makes Alice interact with the blockchain. We can also make Alice
  // send values to the blockchain by giving arguments to the publish function
  Alice.publish();
  
  // Everything from publish() to commit() also happens on the blockchain
  const greet = "Hello World";
  
  commit();

  // Everything from commit() to publish() happens on user's computer and isn't
  // shared with the blockchain

  // This is a short-hand for Alice.only(() => { interact.see(greet) })
  Alice.interact.see(greet);
  exit();
});
