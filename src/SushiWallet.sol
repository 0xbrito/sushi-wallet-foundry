// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "sushiswap/contracts/MasterChefV2.sol";
import "sushiswap/contracts/uniswapv2/interfaces/IUniswapV2Router02.sol";
import "sushiswap/contracts/uniswapv2/libraries/UniswapV2Library.sol";

contract SushiWallet is Ownable {
    IUniswapV2Router02 public s_router;
    IMasterChef public s_masterChef;
    MasterChefV2 public s_masterChefV2;
    address public s_factory;

    constructor(
        address _router,
        address _masterChef,
        address _masterChefV2,
        address _factory
    ) {
        s_router = IUniswapV2Router02(_router);
        s_masterChef = IMasterChef(_masterChef);
        s_masterChefV2 = MasterChefV2(_masterChefV2);
        s_factory = _factory;
    }

    /// @notice User must first send tokens to this contract's address in order to perform this function
    /// @dev Explain to a developer any extra details
    /// @param Documents a parameter just like in doxygen (must be followed by parameter name)
    function deposit(
        address _tokenA,
        address _tokenB,
        uint256 _amountDesiredA,
        uint256 _amountDesiredB
    ) external onlyOwner {
        require(
            _tokenA != address(0) && _tokenB != address(0),
            "SushiWallet: No zero address"
        );

        require(
            IERC20(_tokenA).balanceOf(address(this)) >= _tokenDesiredA,
            "SushiWallet: Insufficient tokenA amount in wallet"
        );
        require(
            IERC20(_tokenB).balanceOf(address(this)) >= _tokenDesiredA,
            "SushiWallet: Insufficient tokenB amount in wallet"
        );

        //save gas
        IUniswapV2Router02 memory router = s_router;

        IERC20(_tokenA).approve(router, _amountDesiredA);
        IERC20(_tokenB).approve(router, _amountDesiredB);

        (, , uint256 liquidity) = router.addLiquidity(
            _tokenA,
            _tokenB,
            _amountDesiredA,
            _amountDesiredB,
            (_amountDesiredA * 97) / 100,
            (_amountDesiredB * 97) / 100,
            address(this),
            block.timestamp + 30 minutes
        );
        address pair = UniswapV2Library.pairFor(s_factory, _tokenA, _tokenB);
    }

    function depositWithETH() external onlyOwner {}

    function withdraw() external onlyOwner {}

    receive() external payable {}
}
