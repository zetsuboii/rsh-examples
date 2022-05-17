'reach 0.1';

const ExampleObject = Object({
  a: UInt,
  b: Bool,
  c: Object({
    d: UInt
  })
});

const ExampleStruct = Struct([
  ['a', UInt],
  ['b', Bool],
  ['c', Struct([
    ['d', UInt]
  ])]
])

const ExampleTuple = Tuple(UInt, Int, Bytes(96))

const ExampleData = Data({
  Type1: UInt,
  Type2: Bool
})

const ExampleArray = Array(UInt, 10)

export const main = Reach.App(() => {
  const Deployer = Participant('Deployer', {
    deployed: Fun([], Null),

    // UInt is an unsigned (positive) integer. It's size depends on the 
    // blockchain. It makes more sense to use positive integers while handling
    // money inside the contract 
    seeUInt: Fun([UInt], Null),
    // UInt256 has size of 256 bits
    seeUInt256: Fun([UInt256], Null),
    // Int is a signed integer, can be both positive and negative
    seeInt: Fun([Int], Null),
    // Bool can be true or false
    seeBool: Fun([Bool], Null),
    // Fixed point is a number with decimal points, it has a specified amount
    // of decimal digits. Fixed point number of scale 3 means it has 3 digits
    // after comma (187,234) 
    seeFixedPoint: Fun([FixedPoint], Null),
    // Bytes(n) is a char array, where n is its size. You can represents strings
    // with Bytes 
    seeBytes1: Fun([Bytes(1)], Null),
    seeBytes128: Fun([Bytes(128)], Null),
    // Digest is a hased value
    seeDigest: Fun([Digest], Null),
    // Address is the information of a user, its actual type depends on the 
    // blockchain
    seeAddress: Fun([Address], Null),
    // Contract is the information of a contract, its actual type depends on
    // the blockchain
    seeContract: Fun([Contract], Null),
    // Token is the information of a Token, its actual type depends on the 
    // blockchain, on Algorand it's ASA ID and on Ethereum it's ERC20 address
    seeToken: Fun([Token], Null),
    // Tuple is a pack of values, you can define it outside the function 
    // declaration or inline it
    seeTuple: Fun([Tuple(UInt, Int, Bytes(96))], Null),
    seeTuple2: Fun([ExampleTuple], Null),
    // Array is a fixed size list
    seeArray: Fun([ExampleArray], Null),
    // Object is a Javascript object
    seeObject: Fun([ExampleObject], Null),
    // Struct is very similar to Object, but is used with Remote calls
    seeStruct: Fun([ExampleStruct], Null),
    // Data is a collection of related types. For example if you have 
    // Data({ A: UInt, B: Bool }), you can type Data.A(100) or Data.B(true)
    seeData: Fun([ExampleData], Null),
    // Refine is a type with pre-conditions, if provided value doesn't satisfy
    // predicate function it will error
    // For example calling seeRefine with 100 will error
    seeRefine: Fun([Refine(UInt, (x => x < 100))], Null)
  });
  init();

  Deployer.publish();
  Deployer.interact.deployed();

  // Type.max return maximum number of the type
  Deployer.interact.seeUInt(UInt.max);
  Deployer.interact.seeUInt256(UInt256.max);
  Deployer.interact.seeInt(-5);
  Deployer.interact.seeBool(false);

  // If a literal is used Reach assumes a base of 10
  Deployer.interact.seeFixedPoint(1.2345);

  // Low level representation of fixed point
  Deployer.interact.seeFixedPoint({
    sign: Pos,
    i: {
      scale: 4, // Number of digits after decimal point
      i: 12345  // Number as an int
    }
  });

  // Shorthand for above syntax
  Deployer.interact.seeFixedPoint(
    fx(4)(Pos, 12345)
  );

  Deployer.interact.seeBytes1("x");
  
  // "x" is one byte long and using Bytes(128).pad() we pad it to 128 bytes 
  Deployer.interact.seeBytes128(Bytes(128).pad("x"));

  const digested = digest("Hello World");
  Deployer.interact.seeDigest(digested);

  const callerInfo = getAddress();
  Deployer.interact.seeAddress(callerInfo);

  const contractInfo = getContract();
  Deployer.interact.seeContract(contractInfo);

  const token = new Token({ 
    name: Bytes(32).pad("MyToken"), 
    symbol: Bytes(8).pad("MYTKN"), 
    supply: 1000000, 
    decimals: 18 
  });
  Deployer.interact.seeToken(token);
  
  Deployer.interact.seeTuple([100, -100, Bytes(96).pad("Tuple")]);
  
  const myArray = array(UInt, [0,1,2,3,4,5,6,7,8,9]); 
  Deployer.interact.seeArray(myArray);

  Deployer.interact.seeObject({
    a: 10,
    b: false,
    c: {
      d: 128
    }
  })

  const myStruct = ExampleStruct.fromObject({
    a: 10,
    b: false,
    c: Struct([["d", UInt]]).fromObject({ d: 128 })
  })

  const myStruct2 = ExampleStruct.fromTuple([
    10, false, Struct([["d", UInt]]).fromTuple([128]) 
  ]);
  assert (myStruct == myStruct2);

  Deployer.interact.seeStruct(myStruct);

  Deployer.interact.seeData(ExampleData.Type1(100));
  Deployer.interact.seeData(ExampleData.Type2(true));

  // Deployer.interact.seeRefine(100); <= This errors
  Deployer.interact.seeRefine(10);

  commit();

  // We need to destroy the token at the end of the contract
  Deployer.publish();
  token.burn();
  token.destroy();
  commit();

  exit();
});
