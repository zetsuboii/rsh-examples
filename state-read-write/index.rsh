'reach 0.1';

export const simpleStorage = Reach.App(() => {
  const Writer = Participant('Writer', {
    getNumberToWrite: Fun([], UInt)
  });
  
  const Reader = Participant('Reader', {
    readNumber: Fun([UInt], Null)
  });

  init();

  // Only block itself doesn't cost gas 
  Writer.only(() => {
    const num = declassify(interact.getNumberToWrite());
  });

  // Publishing requires interaction with blockchain, hence requires txn fees
  // associated the blockchain
  Writer.publish(num);
  
  commit();

  Reader.only(() => {
    interact.readNumber(num);
  });

  exit();
});

export const storageLoop = Reach.App(() => {
  const Deployer = Participant('Deployer', {
    deployed: Fun([], Null)
  });
  
  // Calling API functions require paying fees
  const WriterApi = API('Writer', {
    write: Fun([UInt], Null)
  });

  // Calling view functions doesn't cost any fees
  const ReaderView = View('Reader', {
    read: Fun([], UInt)
  });

  init();
  
  Deployer.publish();
  Deployer.interact.deployed();

  const counter = parallelReduce(0)
    .invariant(balance() == 0)  
    .while(true)
    .define(() => {
      ReaderView.read.set(() => counter);
    })
    .api_(WriterApi.write,
      (num) => {
        return [(respond) => {
          respond(null);
          return num;
        }];
      }
    )
    .timeout(false);
  
  commit();
  exit();
});

