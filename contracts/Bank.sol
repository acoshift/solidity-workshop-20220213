//SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

interface ERC20Mintable is IERC20 {
	function mint(uint256 amount) external;
}

contract Bank is Ownable {
	using SafeERC20 for IERC20;

	event Deposit(address indexed sender, uint256 amount);
	event Withdraw(address indexed sender, uint256 amount);
	event SetFee(address sender, uint256 fee);
	event SetEmission(address sender, uint256 emission);

	struct UserInfo {
		uint256 amount;
		uint256 rewardDebt;
	}

	IERC20 public immutable token;
	ERC20Mintable public immutable bnk;
	mapping (address => UserInfo) public userInfo;

	// 100 => 1%
	// 1 => 0.01%
	uint256 public fee;
	uint256 public constant FEE_DIVIDER = 10000;
	uint256 public constant MAX_FEE = 500; // 5%

	uint256 public emissionPerSec;
	uint256 public lastUpdate;
	uint256 public rewardPerShare;

	constructor(address token_, address bnk_) {
		token = IERC20(token_);
		bnk = ERC20Mintable(bnk_);
	}

	function deposit(uint256 amount) external {
		UserInfo storage user = userInfo[msg.sender];

		update();

		uint256 pendingReward = ((user.amount * rewardPerShare) / 1e12) - user.rewardDebt;
		if (pendingReward > 0) {
			bnk.transfer(msg.sender, pendingReward);
		}

		if (amount > 0) {
			token.safeTransferFrom(msg.sender, address(this), amount);
			user.amount += amount;
		}

		user.rewardDebt = (user.amount * rewardPerShare) / 1e12;

		emit Deposit(msg.sender, amount);
	}

	function withdraw(uint256 amount) external {
		require(amount > 0, "!amount");

		UserInfo storage user = userInfo[msg.sender];

		update();

		uint256 pendingReward = ((user.amount * rewardPerShare) / 1e12) - user.rewardDebt;
		if (pendingReward > 0) {
			bnk.transfer(msg.sender, pendingReward);
		}

		user.amount -= amount;
		uint256 feeAmount = (fee * amount) / FEE_DIVIDER;
		if (feeAmount > 0) {
			token.safeTransfer(owner(), feeAmount);
		}
		token.safeTransfer(msg.sender, amount - feeAmount);

		user.rewardDebt = (user.amount * rewardPerShare) / 1e12;

		emit Withdraw(msg.sender, amount);
	}

	function setFee(uint256 fee_) external onlyOwner {
		require(fee_ <= MAX_FEE, "exceed max fee");

		fee = fee_;
		emit SetFee(msg.sender, fee_);
	}

	function setEmission(uint256 emission) external onlyOwner {
		update();

		emissionPerSec = emission;
		emit SetEmission(msg.sender, emission);
	}

	function update() public {
		uint256 diff = block.timestamp - lastUpdate;
		lastUpdate = block.timestamp;

		uint256 totalSupply = token.balanceOf(address(this));
		if (totalSupply == 0) {
			return;
		}

		uint256 reward = diff * emissionPerSec;
		bnk.mint(reward);
		rewardPerShare = rewardPerShare + ((reward * 1e12) / totalSupply);
	}

	function userPendingReward(address user) public view returns (uint256) {
		UserInfo storage u = userInfo[user];
		uint256 totalSupply = token.balanceOf(address(this));
		uint256 rewardPerShare_ = rewardPerShare;
		if (totalSupply > 0) {
			uint256 diff = block.timestamp - lastUpdate;
			uint256 reward = diff * emissionPerSec;
			rewardPerShare_ = rewardPerShare_ + ((reward * 1e12) / totalSupply);
		}

		return ((u.amount * rewardPerShare_) / 1e12) - u.rewardDebt;
	}
}
