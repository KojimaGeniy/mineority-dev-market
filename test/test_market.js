const { assert } = require('chai');  
const Web3 = require('web3');
const web3 = new Web3(Web3.givenProvider);

const MineorityMarket = artifacts.require("./MineorityMarket")
const FINNEY = 10**15;

contract('MineorityMarket', function(accounts) {
  const [firstAccount, secondAccount] = accounts;
  let funding;
  function sleep(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
  }

  beforeEach(async () => {
    MarketInstance = await MineorityMarket.new();
  });

  // it("queries the IPFS with oraclize", async () => {
  //   await web3.eth.sendTransaction({from: firstAccount, to: MarketInstance.address,value: web3.utils.toWei('0.1','ether')});
  //   await MarketInstance.queryIPFS("QmX69x5XDtV1KFFNkmkL5aGwCsBzfgjzv7PXt1izGRyTDr",{ from: firstAccount,value: 1 });
  //   20000 should work always
  //   await sleep(10000);
  //   console.log(await MarketInstance.res.call("QmX69x5XDtV1KFFNkmkL5aGwCsBzfgjzv7PXt1izGRyTDr"))
  //   assert.isNotEmpty((await MarketInstance.res.call("QmX69x5XDtV1KFFNkmkL5aGwCsBzfgjzv7PXt1izGRyTDr")),"Not returned");
  // });

  // it("check input hash with generated", async () => {
  //   // If hashing a uint in contract, test must be converted to a bytes array
  //   let hash = web3.utils.soliditySha3({v: '0xf17f52151ebef6c7334fad080c5704d77216b732' + '570000000000000000',t: 'string'});
  //   console.log(hash)
  //   assert.equal((await MarketInstance.check.call()),hash)
  // });

  // // TDD in it's real state (failed)
  // it("checks cart from ipfs with input for 1 position", async () => {
  //   // await web3.eth.sendTransaction({from: firstAccount, to: MarketInstance.address,value: web3.utils.toWei('1','ether')});

  //   await MarketInstance.queryIPFS("QmRKJUwsskSFzEjjVGv1S6PLjHUEu9y68A6oaf1uFHaAjq");
  //   await sleep(16000);
  //   await MarketInstance.parse("QmRKJUwsskSFzEjjVGv1S6PLjHUEu9y68A6oaf1uFHaAjq");
  //   // console.log('Raz',await MarketInstance.get.call(0));
  //   console.log('Dva',await MarketInstance.get.call(1));
  //   // console.log('Tri',await MarketInstance.get.call((2));
  //   // await MarketInstance.executeOrder('0xf17f52151ebef6c7334fad080c5704d77216b732',570000000000000000,"QmRKJUwsskSFzEjjVGv1S6PLjHUEu9y68A6oaf1uFHaAjq",{value: 570000000000000000})
  //   await MarketInstance.checkCont('0xf17f52151ebef6c7334fad080c5704d77216b732', 'QmRKJUwsskSFzEjjVGv1S6PLjHUEu9y68A6oaf1uFHaAjq')    

  //   console.log('Sli1',await MarketInstance.sli1.call());
  //   console.log('Sli2',await MarketInstance.sli2.call());
  //   console.log('Control',await MarketInstance.control.call());    

  //   assert.isTrue(await MarketInstance.suc.call());
  // });

  it("calls IPFS and creates invoice", async () => {
    await web3.eth.sendTransaction({from: firstAccount, to: MarketInstance.address,value: web3.utils.toWei('0.8','ether')});
    await MarketInstance.queryIPFS("QmPtyfdTUx4BQRXGK7Twgor1n8GRMK6FhchUMyQX6ourff");
    await sleep(16000);
    // console.log('1Tri',await MarketInstance.get3.call(0,0));
    // console.log('2Tri',await MarketInstance.get3.call(0,1));
    // console.log('3Tri',await MarketInstance.get3.call(0,2));
    // console.log('4Tri',await MarketInstance.get3.call(0,3));
    // console.log('1Tri',await MarketInstance.get3.call(1,0));
    // console.log('2Tri',await MarketInstance.get3.call(1,1));
    // console.log('3Tri',await MarketInstance.get3.call(1,2));
    // console.log('4Tri',await MarketInstance.get3.call(1,3));
    console.log('Suc',await MarketInstance.suc.call());

    console.log('Sanya',(await MarketInstance.getInvoice.call(firstAccount))[0]);
    console.log('Leha',(await MarketInstance.getInvoice.call(firstAccount))[1][0]);
    assert.notEqual((await MarketInstance.getInvoice.call(firstAccount))[0].toNumber(),0);
  });

  // it("pays the invoice and checks for tokens", async () => {
  //   await web3.eth.sendTransaction({from: firstAccount, to: MarketInstance.address,value: web3.utils.toWei('0.1','ether')});
  //   await MarketInstance.queryIPFS("QmRvQMZXoEPzZ7k5tz6WKd4BtFZc6ydMB2Ba6dY7fx2bZB");
  //   await sleep(16000);
  //   await MarketInstance.executeOrder(secondAccount,secondAccount,570000000000000000,{ from:firstAccount, value: 570000000000000000 });
  //   console.log((await MarketInstance.balanceOf.call(secondAccount)).toNumber())
  //   assert.equal((await MarketInstance.balanceOf.call(secondAccount)).toNumber(),1,"No tokens!");
  // });
});
