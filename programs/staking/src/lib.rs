use anchor_lang::prelude::*;
use anchor_spl::token::{self, Token, TokenAccount, Transfer};

declare_id!("YourProgramIDHere");

#[program]
pub mod staking {
    use super::*;

    pub fn initialize(ctx: Context<Initialize>, fee: u64) -> ProgramResult {
        let staking_account = &mut ctx.accounts.staking_account;
        staking_account.fee = fee;
        staking_account.total_staked = 0;
        Ok(())
    }

    pub fn stake(ctx: Context<Stake>, amount: u64) -> ProgramResult {
        let staking_account = &mut ctx.accounts.staking_account;
        let user_account = &mut ctx.accounts.user_account;

        // Transfer tokens from user to staking account
        let cpi_accounts = Transfer {
            from: ctx.accounts.user_token_account.to_account_info(),
            to: ctx.accounts.staking_token_account.to_account_info(),
            authority: ctx.accounts.user.to_account_info(),
        };
        let cpi_program = ctx.accounts.token_program.to_account_info();
        let cpi_ctx = CpiContext::new(cpi_program, cpi_accounts);
        token::transfer(cpi_ctx, amount)?;

        // Update staking account state
        staking_account.total_staked += amount;
        user_account.staked_amount += amount;

        Ok(())
    }

    pub fn distribute_rewards(ctx: Context<DistributeRewards>) -> ProgramResult {
        let staking_account = &mut ctx.accounts.staking_account;
        let winner_account = &mut ctx.accounts.winner_account;

        // Calculate reward amount
        let reward_amount = staking_account.total_staked - (staking_account.total_staked * staking_account.fee / 100);

        // Transfer reward to winner
        let cpi_accounts = Transfer {
            from: ctx.accounts.staking_token_account.to_account_info(),
            to: ctx.accounts.winner_token_account.to_account_info(),
            authority: ctx.accounts.staking_account.to_account_info(),
        };
        let cpi_program = ctx.accounts.token_program.to_account_info();
        let cpi_ctx = CpiContext::new(cpi_program, cpi_accounts);
        token::transfer(cpi_ctx, reward_amount)?;

        // Reset staking account state
        staking_account.total_staked = 0;
        winner_account.staked_amount = 0;

        Ok(())
    }
}

#[derive(Accounts)]
pub struct Initialize<'info> {
    #[account(init, payer = user, space = 8 + 8 + 8)]
    pub staking_account: Account<'info, StakingAccount>,
    #[account(mut)]
    pub user: Signer<'info>,
    pub system_program: Program<'info, System>,
}

#[derive(Accounts)]
pub struct Stake<'info> {
    #[account(mut)]
    pub staking_account: Account<'info, StakingAccount>,
    #[account(init_if_needed, payer = user, space = 8 + 8)]
    pub user_account: Account<'info, UserAccount>,
    #[account(mut)]
    pub user_token_account: Account<'info, TokenAccount>,
    #[account(mut)]
    pub staking_token_account: Account<'info, TokenAccount>,
    pub user: Signer<'info>,
    pub token_program: Program<'info, Token>,
    pub system_program: Program<'info, System>,
}

#[derive(Accounts)]
pub struct DistributeRewards<'info> {
    #[account(mut)]
    pub staking_account: Account<'info, StakingAccount>,
    #[account(mut)]
    pub winner_account: Account<'info, UserAccount>,
    #[account(mut)]
    pub staking_token_account: Account<'info, TokenAccount>,
    #[account(mut)]
    pub winner_token_account: Account<'info, TokenAccount>,
    pub token_program: Program<'info, Token>,
}

#[account]
#[derive(Default, AnchorSerialize, AnchorDeserialize)]
pub struct StakingAccount {
    pub fee: u64,
    pub total_staked: u64,
}

#[account]
#[derive(Default, AnchorSerialize, AnchorDeserialize)]
pub struct UserAccount {
    pub staked_amount: u64,
}
