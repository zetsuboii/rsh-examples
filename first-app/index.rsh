'reach 0.1';

export const main = Reach.App(() => {
  const Deployer = Participant('Deployer', {
    // We'll use this function to observe deployment
    deployed: Fun([], Null)
  });
  
  // Views are functions we can use to see contract's state, very close to
  // view functions in Solidity. You can give names to the views or omit it to
  // have default views
  // View('State', { initialized: Bool }) creates a view with name "State"
  const Views = View({ 
    get: UInt,
  });

  // Actions are functions that users can call without being a participant of
  // the app. They are very close to Solidity functions by means of how we 
  // interact with them. Like Views you can give names to APIs
  // API('User', { call: Fun([], Null )}) creates an API with name "User"
  const Actions = API({
    // An API function has two parameters, what type user gives and what type
    // contract returns. For void functions use Null
    // "inc: Fun([UInt], Null)" is equivalent of "function inc(uint256 v)"
    inc: Fun([UInt], Null),
    dec: Fun([UInt], Null)
  });
  
  init();
  
  // The first one to publish deploys the contract
  Deployer.publish();
  Deployer.interact.deployed();
  
  const count = parallelReduce(0)
    // Invariant has conditions that are always true in the loop.
    // By default, we have to provide invariants for balance and array indices
    // if we have any
    .invariant(balance() == 0)
    // By making this a while(true) loop we are making this program run forever
    .while(true)
    // .define runs before each loop, we generally use it to set views 
    .define(() => {
      Views.get.set(count);
    })
    // We can use .api() or .api_() to handle an API call. Two have slightly 
    // different syntax.
    .api_(
      Actions.inc,  // Name of the call
      (amount) => { // Action to be done for the call. 
        
        // Do the checks here
        
        // To respond, return a tuple where first element is how much user has
        // to pay (optional) and and second element is a function that takes
        // a respond function. If we're going to send user a value will do this
        // by using something like respond(value)
        return [respond => {
          respond(null);

          // This return updates the count
          return count + amount;
        }];
      }
    )
    .api_(
      Actions.dec,
      (amount) => {
        check(amount <= count, "amount is greater than count");
        
        return [respond => {
          respond(null);
          return count - amount;
        }]
      }
    )
    // We don't need a timeout, passing false will disable it
    .timeout(false);
  commit();
  exit();
});
