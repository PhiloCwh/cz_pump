A Crazy Idea for Token Issuance

What if someone issues a token with the following tokenomics?

Initially, 10% of the tokens are unlocked and sold on the market. The proceeds go to the project team to build out the product/platform, marketing, salaries, etc.

Each future unlock must meet ALL of the following conditions:
1. Six months after the previous unlock.
2. ONLY IF the token price has sustained above 2x of the previous unlock price for more than 30 days immediately before the unlock.
3. Up to 5% of tokens maximum each time.

For example, if the TGE was in Jan with a price of $1, by June, if the token price is still less than $2, no more tokens can be unlocked. Let’s say the token's price was above $2 from July 4 to Aug 3, then on Aug 3, 5% more tokens can be unlocked into circulation. Say the price is $3 on Aug 3. The next earliest unlock possible is March 3 next year, and only if the price is above $6 for longer than 30 days.

The project teams have the discretion to delay or reduce the size of each unlock. If they don’t want to sell more, they don’t have to. But the maximum they can sell (unlock) each time is 5%, and then they have to wait for at least another 6 months AND the price to double again.

The project team does NOT have the discretion to shorten or increase the size of the next unlock. The tokens shall be locked by a smart contract where a third party controls the keys.

This avoids new tokens flooding the market when prices are low. It also gives the project team incentives to build for the long term.

I have no plans to issue a new token. Just an idea for discussion.

# BuilderPump Whitepaper

## 1. Overview
BuilderPump is a decentralized fundraising protocol designed to provide developers with a direct financing channel. Developers can launch an IDO (Initial Decentralized Offering) simply by publishing their GitHub repository and setting a custom valuation. The protocol ensures investor protection through a fair liquidity mechanism and strict unlocking rules while incentivizing developers to continuously deliver high-quality projects.

## 2. Core Mechanism
### 2.1 IDO Mechanism
- **GitHub Integration**: Developers must link their GitHub repository with the BuilderPump platform.
- **Custom Valuation**: Developers can freely set their project's initial valuation.
- **Fundraising Ratio**: Developers can raise up to **10%** of the initial valuation.
- **Fundraising Asset**: BNB is used for fundraising.

### 2.2 Fund Allocation
After a successful fundraising event, the BNB funds are distributed as follows:
- **50%**: Added to the liquidity pool to ensure market depth.
- **49%**: Allocated to the developer (DEV) for project development and operations.
- **1%**: Charged as a protocol fee to support the ongoing operation of BuilderPump.

### 2.3 Unlocking Rules
- Each unlocking interval is **at least 1 month**.
- Unlocking is allowed only if the project's **market capitalization reaches 2x the previous unlocking cycle**.
- Only **5%** of the token can be unlocked per cycle.
- This mechanism ensures developers are incentivized to grow their project value rather than seeking short-term gains.

## 3. Tokenomics
BuilderPump uses smart contracts for IDOs, ensuring that all fundraising tokens and unlocking processes are executed transparently on-chain. Developers and investors can query contract data to track the current market cap and unlocking status.

## 4. Future Plans
- **Multi-Chain Expansion**: Support for fundraising on multiple blockchains beyond BNB.
- **GitHub Contribution Rewards**: Additional incentives based on developer activity, such as commits and stars.
- **Decentralized Governance**: Community-driven governance to optimize protocol parameters.

## 5. Conclusion
BuilderPump provides a fair and transparent fundraising channel for developers through the GitHub-based IDO mechanism while ensuring investor fund security. The protocol's innovative unlocking rules encourage long-term project growth, introducing a new fundraising paradigm to the Web3 ecosystem.



# BuilderPump 白皮书

## 1. 概述
BuilderPump 是一个去中心化融资协议，旨在为开发者提供直接融资渠道，开发者只需发布自己的 GitHub 代码库，即可发起 IDO（首次去中心化发行），并按照自定义估值进行融资。该协议通过公平的流动性机制和严格的解锁规则，确保投资者利益，同时激励开发者持续交付高质量项目。

## 2. 核心机制
### 2.1 IDO 机制
- **GitHub 绑定**：开发者需将自己的 GitHub 代码库与 BuilderPump 平台绑定。
- **自定义估值**：开发者可以自由设定项目的初始估值。
- **融资比例**：开发者最多可融资 **10%** 的初始估值。
- **融资资产**：融资采用 BNB 进行。

### 2.2 资金分配
融资成功后，BNB 资金按照以下比例进行分配：
- **50%**：添加至流动性池，确保二级市场的交易深度。
- **49%**：分配给开发者（DEV），用于项目开发、运营等。
- **1%**：作为协议费用，以支持 BuilderPump 平台的持续运作。

### 2.3 解锁规则
- 每次解锁的时间间隔 **至少 1 个月**。
- 只有当项目 **市值达到上一个解锁周期的 2 倍** 时，开发者才可解锁 **5%** 的token。
- 该机制保证开发者有动力持续提升项目价值，而非短期套利。

## 3. 代币经济学
BuilderPump 采用智能合约进行 IDO，所有融资代币及解锁流程均在链上透明执行。开发者和投资者可以通过合约查询当前市值及解锁状态。

## 4. 未来规划
- **多链扩展**：支持除 BNB 之外的多链融资模式。
- **GitHub 贡献激励**：基于开发者的代码提交、Star 数量等数据提供额外奖励。
- **去中心化治理**：通过社区投票优化协议参数。

## 5. 结论
BuilderPump 通过 GitHub 代码库 IDO 机制，为开发者提供公平、透明的融资渠道，同时保证投资者的资金安全。该协议采用创新的解锁规则，确保项目的长期发展，为 Web3 生态带来新的融资范式。
## 5. DAO
1. 建立 DAO
搭建去中心化治理架构，明确投票机制与社区提案流程。

部署链上 NFT 治理系统，每个 NFT 代表一位元老的链上身份，具有不可转让的个人代表性。

治理体系借鉴古罗马元老院制度，设有以下三个等级：

议员（Senator）：持有 Builder Nexus 治理 NFT，拥有基本提案权与投票权。

监察官（Consul）：由议员选举产生，拥有提案优先权与紧急否决权。

元老（Elder）：创始成员或由共识晋升的资深议员，拥有最终仲裁权与元治理权。

治理机制包括：

NFT 为非转让型身份凭证（Soulbound），绑定个体的链上身份，代表其在社区的治理地位与历史贡献。

所有提案需经由议员提出并获得 2/3 支持，再经监察官审批。

元老拥有每季度一次的最终否决权，用于制衡潜在风险提案，确保社区长期稳定发展。


1. 议员（Senator）
资格获取方式：持有 Builder Nexus 标准 NFT 即自动拥有议员身份。

数量限制：无限制，代表 Builder Nexus 的公民阶层。

权利：

拥有投票权（治理提案、预算使用等）。

每持有 1 枚 NFT 可获得 1 个治理权重（可设置上线防止鲸鱼垄断）。

2. 监察官（Consul）
选举周期：每 90 天由议员投票选出 2 名监察官。

候选资格：

至少持有 NFT 30 天以上。

在上一个治理季度内参与过不少于 3 次投票。

职责与权利：

审核社区提案的合规性和风险。

拥有“一票否决权”，但必须联署两名监察官共同否决方可生效。

可临时冻结提案进入执行流程（最长 7 天）。

3. 元老（Elder）
产生方式：

由创世团队指定初始若干名元老。

后续新增元老需由现任元老 2/3 以上投票通过。

权利与限制：

拥有最终仲裁权，用于处理重大分歧（例如合约升级、重大资产转移等）。

每季度最多可行使一次“最终否决权”。

✅ 选举流程建议（以链上投票合约实现）
候选人提交自荐或由他人提名（含说明）。

社区进入公开提问阶段（3~5 天）。

开启链上投票，NFT 持有者按权重投票（可使用 Snapshot、Tally 等工具）。

公布当选结果，新的治理角色上任。



