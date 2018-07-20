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

  it("queries the IPFS with oraclize", async () => {
    // await web3.eth.sendTransaction({from: firstAccount, to: MarketInstance.address,value: web3.toWei(0.1,'ether')});
    await MarketInstance.queryIPFS("QmX69x5XDtV1KFFNkmkL5aGwCsBzfgjzv7PXt1izGRyTDr",{ from: firstAccount,value: 1 });
    await sleep(10000);
    console.log(await MarketInstance.res.call("QmX69x5XDtV1KFFNkmkL5aGwCsBzfgjzv7PXt1izGRyTDr"))
    assert.isNotEmpty((await MarketInstance.res.call("QmX69x5XDtV1KFFNkmkL5aGwCsBzfgjzv7PXt1izGRyTDr")),"Not returned");
  });

  it("check input hash with generated", async () => {
    // If hashing a uint in contract, test must be converted to a bytes array
    let hash = web3.utils.soliditySha3({v: '0xf17f52151ebef6c7334fad080c5704d77216b732' + '570000000000000000',t: 'string'});
    
    assert.equal((await MarketInstance.check.call()),hash)
  });


  // TDD in it's real state
  // it("should check cart from ipfs with input for 1 position", async () => {
  //   await MarketInstance.queryIPFS("QmX69x5XDtV1KFFNkmkL5aGwCsBzfgjzv7PXt1izGRyTDr");
  //   await sleep(10000);

  // });
});
