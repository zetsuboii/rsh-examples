import {loadStdlib} from '@reach-sh/stdlib';
import * as backend from './build/index.main.mjs';
const stdlib = loadStdlib(process.env);

const startingBalance = stdlib.parseCurrency(100);

const deployerAccount = await stdlib.newTestAccount(startingBalance);

const deployerContract = deployerAccount.contract(backend);

const labelLog = lbl => (x) => console.log(lbl, x)

await Promise.all([
  deployerContract.p.Deployer({
    deployed: () => { console.log("Contract is deployed") },



    seeUInt: labelLog('seeUInt'),
    seeUInt256: labelLog('seeUInt256'),
    seeInt: labelLog('seeInt'),
    seeBool: labelLog('seeBool'),
    seeFixedPoint: labelLog('seeFixedPoint'),
    seeBytes1: labelLog('seeBytes1'),
    seeBytes128: labelLog('seeBytes128'),
    seeDigest: labelLog('seeDigest'),
    seeAddress: labelLog('seeAddress'),
    seeContract: labelLog('seeContract'),
    seeToken: labelLog('seeToken'),
    seeTuple: labelLog('seeTuple'),
    seeTuple2: labelLog('seeTuple2'),
    seeArray: labelLog('seeArray'),
    seeObject: labelLog('seeObject'),
    seeStruct: labelLog('seeStruct'),
    seeData: labelLog('seeData'),
    seeRefine: labelLog('seeRefine')
  }),
]);
