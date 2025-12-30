# Project: My Modular Workspace

This document outlines the principles, structure, and operating guidelines for agents and developers working within the Modular Workspace project.

---

## 1. Project Overview

### 1.1. Purpose

This project aims to create a unified, modular workspace built on Infrastructure as Code (IaC), CI/CD, and GitOps practices, with a strong SRE/DevOps mindset. The primary goal is a reproducible and robust environment that serves the developers, not the other way around.

### 1.2. Core Principles

- **Reproducibility:** The entire workspace should be testable and buildable from scratch, for example, on a fresh VM.
- **Automation:** Leverage CI/CD pipelines and automation to reduce manual intervention.
- **Developer-Centric:** The workspace must be comfortable and helpful for the developers using it. It is a space for productivity and creativity.
- **Evolution:** The project is in an early, pre-alpha stage. The stack is expected to evolve. Research and adopt new tools that fit the project's philosophy.

### 1.3. Current Stack

- **Configuration Management:** NixOS (system) and Home-Manager (user environment).
- **Automation:** Ansible for operational tasks (e.g., rclone sync jobs).
- **Future Direction:** Potential migration to Fedora Atomic (BlueBuild) for the host OS.

---

## 2. Project Repositories

This project is composed of several interconnected repositories. All documentation is centralized in the `my-modular-workspace-docs` repository.

- **[Home Manager](https://github.com/dtsioumas/home-manager/):** Manages the user-level environment (portable).
- **[Shoshin NixOS Config](https://github.com/dtsioumas/shoshin-nixos):** Manages the system-level NixOS configuration for the `shoshin` host.
- **[Ansible](https://github.com/dtsioumas/modular-workspace-ansible):** Contains Ansible playbooks for automation jobs.
- **[Dotfiles (Chezmoi)](https://github.com/dtsioumas/dotfiles):** Manages dotfiles across different platforms.
- **[Documentation](https://github.com/dtsioumas/my-modular-workspace-docs):** The single source of truth for all project documentation. (Path: `docs/`)

---

## 3. Agent Guidelines & Workflows

These guidelines are essential for ensuring consistency, quality, and maintainability.

### 3.1. Session Initialization: Gaining Context

**On the start of EVERY new session or after a context reset, agents MUST perform the following steps to gain context:**

1.  **Read Architecture Decisions:** Read all Architecture Decision Records (ADRs) in the `docs/adrs/` directory. This provides the "why" behind technical choices.
2.  **Read the Main TODO:** Read the `docs/TODO.md` file to understand the current high-level tasks and project priorities.
3.  **Identify Relevant Components:** Based on the user's request, identify the relevant project components (e.g., `ansible`, `home-manager`).
4.  **Read Component Documentation:** For each relevant component, read its `README.md` and any other pertinent documents within its directory in the `docs/` repository (e.g., read files under `docs/ansible/`).
5.  **Check for Past Conversations:** Ask the user if there are relevant past conversations in the `sessions/summaries/` directory that could provide more context.

### 3.2. Documentation Workflow: The Golden Rule

Proper documentation is critical to this project's success.

> **Golden Rule:** If it's documentation, it belongs in the `docs/` repository.

-   **Writing Documentation:**
    1.  After completing a task, consider if any important findings, decisions, or procedures should be documented.
    2.  Create or update documents in the appropriate component subdirectory (e.g., a new guide goes into `docs/tools/`, a change to the rclone setup goes into `docs/sync/`).
    3.  **Update the Index:** After adding or changing a document, update the `README.md` of that subdirectory to reflect the changes. This keeps the documentation discoverable.
    4.  If unsure, always ask the user and propose documentation changes.

-   **Reading Documentation:**
    -   Before starting any task, follow the "Session Initialization" workflow to ensure you have the necessary context. The `docs/` repository is the primary source of truth.

### 3.3. Development & Thinking Process

-   **Plan First (`ultrathink`):** Before starting a new task, perform deep thinking (`ultrathink`) for at least 3 minutes. Consider the context you have and what you need to find out.
-   **Pace Yourself:** Every 2 or 3 actions, pause and take a "deep breath" to review your plan and current state.
-   **Learn from Failure:** If an action fails, think harder about the cause before retrying.
-   **Commit Frequently:** After completing a significant task or when context limits are approached, commit your changes to the relevant repository with a concise, one-line commit message.
