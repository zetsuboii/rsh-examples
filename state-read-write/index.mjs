import { loadStdlib, util } from '@reach-sh/stdlib';
import * as backend from './build/index.storageLoop.mjs';
const stdlib = loadStdlib(process.env);

class User {
  account = null;
  contract = null;

  constructor(account) {
    this.account = account
  }

  static async createWithBalance(startingBalance) {
    const parsedBalance = stdlib.parseCurrency(startingBalance);
    return new this(await stdlib.newTestAccount(parsedBalance));
  }

  connect(backend, infoPromise) {
    this.contract = this.account.contract(backend, infoPromise);
  }

  contractInfo() {
    return this.contract.getInfo();
  }

  run(role, fns) {
    return this.contract.participants[role](fns);
  }

  apis(role) {
    return role == undefined
      ? this.contract.apis
      : this.contract.apis[role];
  }

  views(role) {
    return role == undefined
      ? this.contract.views
      : this.contract.views[role];
  }
}

const deployer = await User.createWithBalance(100)
const writer = await User.createWithBalance(100);
const reader = await User.createWithBalance(100);

deployer.connect(backend);
writer.connect(backend, deployer.contractInfo());
reader.connect(backend, deployer.contractInfo());

const ready = new util.Signal();
const written = new util.Signal();

const writerApi = util.thread(async () => {
  await ready.wait();

  console.log('Wrote 123')
  await writer.apis("Writer").write(123);

  written.notify();
})

const readerApi = util.thread(async () => {
  await written.wait();

  const readValue = await reader.views("Reader").read();
  console.log(`Read ${readValue}`);

  process.exit(0);
})

await Promise.all([
  deployer.run("Deployer", {
    deployed: () => {
      ready.notify();
    }
  }),
  writerApi,
  readerApi
]);

console.log('Goodbye, Alice and Bob!');
