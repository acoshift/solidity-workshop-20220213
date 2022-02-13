//SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract BankToken is ERC20Burnable, Ownable {
	constructor() ERC20("Bank Token", "BNK") {
		_mint(msg.sender, 1_000_000 ether);
	}

	function mint(uint256 amount) external onlyOwner {
		_mint(msg.sender, amount);
	}
}
