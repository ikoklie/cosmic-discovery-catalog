# 🌌 Cosmic Discovery Catalog

A Clarity smart contract for decentralized registration, validation, categorization, and controlled sharing of celestial observations. Built to power astronomy projects and open scientific data initiatives with on-chain verifiability.

---

## 📦 Features

- Register new cosmic discoveries with metadata
- Enforce validation on entry titles, abstracts, sizes, and categories
- Control visibility with access permissions per entry
- Update and delete entries securely (owner-only)
- Retrieve full, minimal, or specific entry details for display
- Optimized read-only functions for minimal gas use

---

## 📚 Data Structures

- `celestial-entries` – Main registry for observations (ID → metadata)
- `entry-access-rights` – Fine-grained visibility permissions (ID + viewer → bool)
- `entry-sequence` – Monotonic counter for generating unique IDs

---

## 🔐 Access Control

Only the registering principal can:
- Update or delete their own entries
- Grant or retain viewing rights upon registration

All view-related functions return `err u301` if an entry does not exist or if access is restricted.

---

## ⚠️ Error Codes

| Code      | Meaning                        |
|-----------|--------------------------------|
| `u300`    | Unauthorized access            |
| `u301`    | Entry does not exist           |
| `u302`    | Entry already exists           |
| `u303`    | Invalid title or abstract      |
| `u304`    | Invalid entry size             |
| `u305`    | Access restricted              |

---

## 🛠️ Key Public Functions

| Function                    | Purpose                                  |
|----------------------------|------------------------------------------|
| `register-discovery`       | Add a new celestial entry                |
| `log-cosmic-finding`       | Alias for registering entries            |
| `update-discovery`         | Modify existing entry (owner only)       |
| `purge-discovery`          | Delete an entry (owner only)             |
| `display-entry-card`       | Retrieve formatted display data          |
| `retrieve-full-entry`      | Get complete metadata                    |
| `retrieve-entry-basic`     | Gas-efficient core info                  |
| `retrieve-entry-identifier`| Minimal identifying metadata             |
| `validate-entry-parameters`| Validate fields before submission        |

---

## 📦 Requirements

- [Stacks blockchain](https://www.stacks.co/)
- Clarity language support
- Suitable frontend or CLI for interaction

---

## 📄 License

MIT License — see `LICENSE` file for details.

---

## 🌠 About

This project supports decentralized science (DeSci) efforts and astronomy-focused DAOs aiming to keep cosmic knowledge open, verifiable, and immutable.

