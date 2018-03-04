const assert = require('assert');
const ganache = require('ganache-cli');
const Web3 = require('web3');

const { interface: iface, bytecode } = require('../compile');

const web3 = new Web3(ganache.provider());

let accounts;
let inbox;

const defaultGas = '5000000';

beforeEach(async () => {
  accounts = await web3.eth.getAccounts();

  // iface is the json interface
  ets = await new web3.eth.Contract(JSON.parse(iface))
    .deploy({ data: bytecode, arguments: [] })
    .send({ from: accounts[0], gas: defaultGas});
})

describe('ETS', () => {
  it('sets the creator', async () => {
    let creator = await ets.methods.creator().call();
    assert.equal(creator, accounts[0]);
  });

  it('registers firms', async () => {
    await ets.methods.registerFirm(accounts[1], "foo", 10).send({
      from: accounts[0],
      gas: defaultGas
    });

    assert.ok(await ets.methods.firms(accounts[1]).call())
  });

  // it('only allows the creator to register firms', () => {
  //   assert.throws(
  //     async () => {
  //         await ets.methods.registerFirm(accounts[1], "foo", 10).send({
  //         from: accounts[1],
  //         gas: defaultGas
  //       });
  //     }
  //   );
  // });

  describe('buying credits', () => {
    it('buys credits', async () => {
      await ets.methods.registerFirm(accounts[1], "bar", 10).send({
        from: accounts[0],
        gas: defaultGas
      });

      await ets.methods.buyCredits().send({
        from: accounts[1],
        gas: defaultGas,
        value: web3.utils.toWei('10', 'ether')
      });

      let firm = await ets.methods.firms(accounts[1]).call();
      let balance = firm['2'];
      let used = firm['3'];
      // because the cheap price is 2, so 10 / 2
      assert.equal(balance, 5);
      assert.equal(used, 5);
    });

    it('buys expensive credits', async () => {
      await ets.methods.registerFirm(accounts[1], "bar", 5).send({
        from: accounts[0],
        gas: defaultGas
      });

      await ets.methods.buyCredits().send({
        from: accounts[1],
        gas: defaultGas,
        value: web3.utils.toWei('20', 'ether')
      });

      let firm = await ets.methods.firms(accounts[1]).call();
      let balance = firm['2'];
      let used = firm['3'];
      // because the cheap price is 2, so 10 / 2
      assert.equal(balance, 6);
      assert.equal(used, 6);
    });
  });

  // it('transfers credits', async () => {
  //   let firm2 = ets.methods.registerFirm(address[1], "bar", 10).send({
  //     from: accounts[0],
  //     gas: defaultGas,
  //   });
  //   ets.methods.transferCredits(address[0], 5);
  // });
});
