const MineorityMarket = artifacts.require("MineorityMarket")

contract('MineorityMarket', function(accounts) {
  it("should assert true", function(done) {
    var test_market = MineorityMarket.deployed();
    assert.isTrue(true);
    done();
  });
});
