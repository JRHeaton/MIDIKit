module.exports = Object.create(MKMessage)

module.exports.TestMsg = function() {
    return this.message(0x90, 0x30, 127);
}

module.exports.Reset = function() {
    return this.message(0xb0, 0x00, 0x00);
}