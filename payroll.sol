/* caveat:
   this codebase was a personal development thing.
   leanred how to build this payroll from https://coinsbench.com/payroll-contract-with-solidity-6c37a2cc874c
*/

//@paulelisha18 contributed to this codebase

// SPDX-License-Identifier: MIT;
  
  pragma solidity ^ 0.8.17;

  import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

  contract Payroll{
    error Allowed();
    address employer;
  
    IERC20 private immutable BUSD;

    // show workings with mappings of addresses and their corresponding permmissions.

    mapping (address => bool) allowed;
    mapping (address => uint) allowance;
    mapping (address => uint) moment;
    mapping (address => uint) residual;

    constructor (address _BUSD) {
        employer = msg.sender;
        BUSD = IERC20(_BUSD);
    }

    // add a modifier for security

    modifier onlyOwner() {
      require(msg.sender == employer);
      _;
    }

    modifier addressAllowed(address _address) {
      if(!allowed[_address]) revert Allowed();
      _;
    }

    // let's spell out the functions

    function addEmployee(address _address, uint _allowance) external onlyOwner addressAllowed(_address){
      moment [_address] = block.timestamp;
      allowance [_address] = _allowance * 1 ether;
      allowed [_address] = true;
    }

    function claim() external {
      // we cannot use the multiplication sign with mappings
      // so it is better to reset them locally now
      // if you try it, it will bring a Built-in Binary error 

      uint _moment = moment [msg.sender];
      uint _allowance = allowance [msg.sender];
      uint amount = (((block.timestamp - _moment) / 1 hours) * _allowance) + residual[msg.sender];

      // put checks in place

      require(amount > 0, "You cannot have nothing, bruh.");
      
      uint bal = BUSD.balanceOf(address(this));

      if(bal < amount){
      uint _residual = amount - bal;
      BUSD.transfer(msg.sender, bal);
      moment[msg.sender] = block.timestamp;
      residual[msg.sender] = _residual;
      } else{
          BUSD.transfer(msg.sender, amount);
          moment [msg.sender] = block.timestamp;
          residual [msg.sender] = 0;
      }
    }

    function updateAllowance(address _address, uint _amount) external onlyOwner addressAllowed(_address) {
        allowance [_address] = _amount * 2 ether;
    }

    function transferControl(address _address) private onlyOwner {
        employer = _address;
    }

    // set the getter functions

    function checkDueRewards(address _address) external view returns (uint) {
        uint _moment = moment [_address];
        uint _allowance = allowance [_address];

        uint result = (((block.timestamp - _moment) / 1 hours) * _allowance + residual [_address]);
        return result;
    } 

    function getAddressStatus (address _address) view external onlyOwner returns (bool) {
        return allowed[_address];
    }
     
  }
