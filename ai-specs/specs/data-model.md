# YOM Data Model Reference

This document is a **workspace-level overview** of YOM's data architecture. It describes which services own which data, the shared domain concepts, and the cross-cutting patterns that apply across all services.

> **Note:** Actual schema definitions (collections, fields, validations, indexes) live in each service's own repository. Refer to the individual service's `CLAUDE.md` or `src/` directory for authoritative schema details.

---

## Architecture: Service-Owned Data

YOM follows a **microservices architecture** where each service owns its data store. There is no shared database. Services communicate via NATS (event bus) or HTTP through the API gateway.

```
yom-gateway (port 3100)
    └── routes to individual services

Each service owns its own DB:
    customer    → MongoDB
    fintech     → MongoDB
    orders      → MongoDB
    products    → PostgreSQL
    yom-api     → MongoDB + PostgreSQL
    chatbot-api → own schema
    hermes      → own schema
```

---

## Services and Their Databases

| Service | Framework | Database | Primary Responsibility |
|---------|-----------|----------|----------------------|
| `customer` | NestJS | MongoDB | FAQs, banners, T&Cs, announcements per customer |
| `fintech` | NestJS | MongoDB | Payment providers (Khipu, Getnet), payment documents |
| `orders` | NestJS | MongoDB | Order management and lifecycle |
| `products` | NestJS | PostgreSQL | Product catalog (relational model) |
| `yom-api` | Moleculer | MongoDB + PostgreSQL | Core platform data: users, commerces, sellers |
| `chatbot-api` | NestJS | own schema | Chatbot conversation and configuration data |
| `hermes` | FastAPI (Python) | own schema | Notification delivery and messaging |

For schema details of each service, see the service's `CLAUDE.md`.

---

## Core Domain Concepts

### Customer (Tenant)
The top-level entity. A **Customer** is a B2B company that uses the YOM platform. All tenant-scoped data is keyed by `customerId`.

- Owns: banners, FAQs, T&Cs, announcements (via `customer` service)
- Has: one or more Commerces

### Commerce
A **store** belonging to a Customer. A Customer may have multiple Commerces.

- Belongs to: Customer (`customerId`)
- Has: Products, Orders, Sellers

### Seller
A **seller user** operating within a Commerce. Managed in `yom-api`.

- Belongs to: Customer + Commerce

### Banner
A **promotional banner** shown in the B2B platform. Stored in `customer` service, scoped to `customerId`.

### FAQ
A **frequently asked question** entry shown in the B2B platform. Stored in `customer` service, scoped to `customerId`.

### Order
A **purchase order** from a buyer to a seller. Managed in the `orders` service.

- Scoped to: `customerId`
- References: Commerce, Seller, Products

### Product
A **catalog item** available for purchase. Managed in `products` service (PostgreSQL).

- Scoped to: Customer + Commerce
- Relational model — see `products` service schema

### Payment Document
An **invoice or credit note** generated for a transaction. Managed in `fintech` service.

- Scoped to: `customerId`
- References: Order, Commerce

---

## Cross-Cutting Patterns

### Multi-Tenancy via `customerId`

`customerId` is the **tenant discriminator** across the entire platform.

- **Every MongoDB document** in every service must include a `customerId` field.
- **Every query** against a tenant-scoped collection must filter by `customerId`. Omitting it is a critical bug — it would return or mutate data across tenants.
- Services enforce this at the repository/service layer, not at the database level.

```typescript
// Correct — always scope by customerId
await this.bannerModel.find({ customerId, isActive: true });

// Wrong — missing tenant scope
await this.bannerModel.find({ isActive: true });
```

### Standard Audit Fields

All MongoDB documents include audit timestamps via Mongoose's `timestamps` option:

- `createdAt`: set automatically on document creation
- `updatedAt`: updated automatically on every save

NestJS services declare this at the schema level:

```typescript
@Schema({ timestamps: true })
export class Banner {
  @Prop({ required: true })
  customerId: string;

  // ... other fields
}
```

PostgreSQL services (`products`, `yom-api`) manage timestamps via ORM or raw SQL conventions — see individual service schemas.

### Mongoose Schema Pattern (NestJS)

MongoDB-backed NestJS services use `@nestjs/mongoose` with decorator-based schemas:

```typescript
import { Schema, SchemaFactory, Prop } from '@nestjs/mongoose';
import { Document } from 'mongoose';

@Schema({ timestamps: true })
export class MyEntity extends Document {
  @Prop({ required: true, index: true })
  customerId: string;

  @Prop({ required: true })
  name: string;
}

export const MyEntitySchema = SchemaFactory.createForClass(MyEntity);
```

### PostgreSQL Pattern (products, yom-api)

`products` uses a relational model. `yom-api` uses both MongoDB (for user/commerce documents) and PostgreSQL. These services use raw SQL queries or an ORM — refer to each service's `CLAUDE.md` for the specific approach.

---

## Domain Relationship Overview

```
Customer (customerId)
├── Commerces[]
│   ├── Sellers[]
│   ├── Products[]       (products service — PostgreSQL)
│   └── Orders[]         (orders service — MongoDB)
│       └── PaymentDocuments[]  (fintech service — MongoDB)
├── Banners[]            (customer service — MongoDB)
├── FAQs[]               (customer service — MongoDB)
├── T&Cs[]               (customer service — MongoDB)
└── Announcements[]      (customer service — MongoDB)
```

---

## Where to Find Actual Schemas

| Service | Location |
|---------|----------|
| `customer` | `local-architecture/systems/customer/CLAUDE.md` |
| `fintech` | `local-architecture/systems/fintech/CLAUDE.md` |
| `orders` | `local-architecture/systems/orders/CLAUDE.md` |
| `products` | `local-architecture/systems/yom-catalog/CLAUDE.md` |
| `yom-api` | `local-architecture/systems/yom-api/CLAUDE.md` |
| `chatbot-api` | `local-architecture/systems/chatbot-api/CLAUDE.md` |
| `hermes` | `local-architecture/systems/hermes/CLAUDE.md` |
