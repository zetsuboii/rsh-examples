'reach 0.1';

const PayerInterface = {
  payNetworkToken: Fun([], UInt),
  payNonNetworkToken: Fun([], UInt),
  payCombination: Fun([], Tuple(UInt, UInt, UInt))
}

export const main = Reach.App(() => {
  const Payer = Participant('Payer', PayerInterface);
  init();
  
  Payer.only(() => {
    // Get how many network tokens user wants to pay
    const paymentAmount = declassify(interact.payNetworkToken());
  });

  // In order to pay depending on a variable, we have to first publish that
  // variable then use it inside the .pay() function
  Payer.publish(paymentAmount).pay(paymentAmount);
  commit();

  /* This is equivalent of the following lines
  Payer.publish(paymentAmount);
  Payer.pay(paymentAmount);
  commit(); */


  exit();
});
