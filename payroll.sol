/* caveat:
   this codebase was a personal development thing.
   leanred how to build this payroll from https://coinsbench.com/payroll-contract-with-solidity-6c37a2cc874c
*/

// SPDX-License-Identifier ; MIT
  
  pragma solidity ^ 0.8.17;

  import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/IERC20.sol";

  contract Payroll{
  
  address employer;
  
  IERC20 BUSD = IERC20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);

  // show workings with mappings of addresses and their corresponding permmissions.

  mapping (address => bool) allowed;
  mapping (address => uint) allowance;
  mapping (address => uint) moment;
  mapping (address => uint) residual;

  constructor () public {
      employer = msg.sender;
  }

  // add a modifier for security

  modifier onlyOwner() {
      require(msg.sender == employer);
      _;
  }

  // let's spell out the functions

  function addEmployee(address _address, uint _allowance) external onlyOwner {
     allowed [_address] = true;
     moment [_address] = block.timestamp;
     allowance [_address] = _allowance * 1 ether;

  }

  function claim() external {
    // we cannot use the multiplication sign with mappings
    // so it is better to reset them locally now
    // if you try it, it will bring a Built-in Binary error 

    uint _moment = moment [msg.sender];
    uint _allowance = allowance [msg.sender];
    uint amount = (((block.timestamp - _moment) / 1 hours) * _allowance) + residual[msg.sender];

    // put checks in place

    require(allowed[msg.sender] == true,"The employer didn't allow this specific address to withdraw");
    require(amount > 0, "You cannot have nothing, bruh.");

    if(BUSD.balanceOf(address(this)) < amount){
     uint _residual = amount - BUSD.balanceOf(address(this));
     BUSD.transfer(msg.sender, BUSD.balanceOf(address(this)));
     moment[msg.sender] = block.timestamp;
     residual[msg.sender] = _residual;
    } else{
        BUSD.transfer(msg.sender, amount);
        moment [msg.sender] = block.timestamp;
        residual [msg.sender] = 0;
    }
  }

  function updateAllowance(address _address, uint _amount) external onlyOwner {
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
