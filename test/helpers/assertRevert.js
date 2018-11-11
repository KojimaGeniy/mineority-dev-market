async function assertRevert(promise,mess) {
    try {
      await promise;
      assert.fail('Expected revert');
    } catch (err) {
      var re = new RegExp(mess, "g");
      assert.ok(re.test(err.message));
    }
  }
module.exports = assertRevert;