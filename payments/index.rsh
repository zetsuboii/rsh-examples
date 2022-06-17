'reach 0.1';

const PayerInterface = {
  // Gets amount of network tokens to pay
  // () => UInt
  payNetworkToken: Fun([], UInt),

  // Gets tokens we're going to spend in the application
  // () => Token (Address on Ethereum and UInt on Algorand)
  getUSDC: Fun([], Token),
  getWBTC: Fun([], Token),

  // Gets amount of non-network tokens to pay
  // () => UInt
  payNonNetworkToken: Fun([], UInt),

  payCombination: Fun([], Tuple(UInt, UInt, UInt))
}

// Before we start it is important to know about network tokens and non-network
// tokens. 
// Network tokens are the native tokens of the network. By network we generally
// mean a blockchain but it can be really any place where Reach would compile to
// - On Ethereum, the network token is ether 
// - On Algorand, the network token is algo
// - On Conflux, the network token is conflux
// Non-network tokens are the tokens that other users have created on the 
// network.
// - On Ethereum & Conflux, the non-network tokens are ERC20 tokens* represented
//   by addresses
// - On Algorand, the non-network tokens are ASAs represented by ASA IDs
//
// * Reach's Token representation won't account for each ERC20 tokens unique
//   mechanics, instead it is a generalization of an ERC20. This example will
//   demonstrate an another way to interact with a ERC20 token

export const main = Reach.App(() => {
  const Payer = Participant('Payer', PayerInterface);
  init();

  // You can use .pay() to get payment from the participant
  Payer.pay(1);

  // You can then the funds on the contract using transfer().to();
  transfer(1).to(Payer);
  commit();
  
  Payer.only(() => {
    // Get how many network tokens user wants to pay
    const paymentAmount = declassify(interact.payNetworkToken());
  });

  // In order to pay depending on a variable, we have to first publish that
  // variable then use it inside the .pay() function
  Payer.publish(paymentAmount).pay(paymentAmount);
  commit();

  /* This is equivalent of the previous lines
  Payer.publish(paymentAmount);
  Payer.pay(paymentAmount);
  commit(); */

  // In Reach, before we can use a non-network token inside the application we 
  // have to first introduce it to the contract. This happens by one participant 
  // publishing the token to the contract. Token is the type used for any 
  // non-network token. On EVM-like it is the address of the ERC20 token and
  // on Algorand it is the ASA id 
  Payer.only(() => {
    const tokenAmount = declassify(interact.payNonNetworkToken());
    const USDC = declassify(interact.getUSDC());
  });

  // While paying non-network tokens, we have to use a array of tuples where
  // each tuple has (<token>, <amount of the token>) format.
  // So if we were to spend 100 USDCs of id 123 we have to write
  // ```reach
  // Payer.pay([ [100, 123] ]); 
  // ```
  // It is also possible to combine different payments inside a single 
  // expression. If we want to pay 100 ALGOs, 200 USDCs and 300 WBTCs we can
  // write
  // ```reach
  // const Payer = Participant('Payer', { 
  //   getTokens: Fun([], Tuple(Token, Token))
  // }})
  // ...
  // Payer.only(() => {
  //   const [USDC, WBTC] = declassify(interact.getTokens())
  // });
  // Payer.pay([ 100, [200, USDC], [300, WBTC] ])
  // ```
  Payer.publish(USDC, tokenAmount).pay([ [tokenAmount, USDC] ]);

  // You can use the .transfer().to() syntax for tokens transfers as well
  transfer([ [tokenAmount, USDC] ]).to(Payer);

  commit();
  exit();
});
