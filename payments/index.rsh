'reach 0.1';

const PayerInterface = {

}

export const main = Reach.App(() => {
  const Payer = Participant('Payer', PayerInterface);
  init();

  Payer.publish();

  commit();
  exit();
});
