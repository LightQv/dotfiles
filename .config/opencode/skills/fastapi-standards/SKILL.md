---
name: fastapi-standards
description: Use when building or reviewing FastAPI, Pydantic, SQLAlchemy, Alembic, route, service, repository, validation, or Python API code.
---

## Architecture

- Repository code, dependency versions, configuration, tests, and established paths are the source of truth.
- Discover routes under patterns such as `app/routes/` or `app/api/routes/`, and schemas under `app/dto/`, `app/dtos/`, or `app/schemas/`.
- Preserve existing layering. Do not create validators, repositories, or service layers merely because this skill lists them.
- Use official FastAPI, Pydantic, SQLAlchemy, and Alembic documentation matching installed major versions when repository guidance is absent.

## Code Standards

- Apply ruff lintering and formatting from `ruff.toml`
- **Everything** newly declared must have type hints : includes function signatures/arguments, variables, class attributes
- Use modern f-strings for string formatting
- Follow PEP8 naming conventions: `snake_case` for variables/functions, `PascalCase` for classes
- Follow repository docstring style; default to Google docstrings for non-route functions/classes

## Route Standards

- Use DTOs for input validation and `response_model` DTOs for output
- Include `status_code` and `responses` for documentation
- Inject services via `Depends()`
- Inject authenticated user when needed: `Depends(authentication_required)`
- Docstring documentation in markdown format for a beautiful Swagger UI

## Pydantic Standards

### Field Configuration

Use `Field()` to customize field behavior:

```python
from pydantic import BaseModel, Field
from typing import Annotated

class UserCreate(BaseModel):
    name: Annotated[str, Field(
        min_length=1,
        max_length=50,
        description="User's full name"
    )]
    email: Annotated[str, Field(
        pattern=r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$",
        description="User's email address"
    )]
    age: Annotated[int, Field(
        ge=0,
        le=120,
        description="User's age in years"
    )]
    is_active: Annotated[bool, Field(
        default=True,
        description="Whether the user account is active"
    )]
```

**Common Field Parameters:**

| Parameter                | Purpose                             |
| ------------------------ | ----------------------------------- |
| `default`                | Default value for field             |
| `default_factory`        | Callable to generate default value  |
| `alias`                  | Field name mapping                  |
| `description`            | Documentation for Swagger/OpenAPI   |
| `examples`               | Example values for documentation    |
| `title`                  | Custom field title for docs         |
| `frozen`                 | Make field immutable after creation |
| `validate_default`       | Validate default value on creation  |
| `exclude` / `exclude_if` | Control serialization inclusion     |

### Validators

Use `@field_validator` for field-level validation:

```python
from pydantic import BaseModel, field_validator, ValidationInfo

class UserCreate(BaseModel):
    password: str
    confirm_password: str

    @field_validator('confirm_password')
    @classmethod
    def passwords_match(cls, value: str, info: ValidationInfo) -> str:
        if value != info.data.get('password'):
            raise ValueError('Passwords do not match')
        return value
```

**Validator Modes:**

- `mode='after'` - Run after Pydantic's validation (default)
- `mode='before'` - Run before Pydantic's validation, receive raw input
- `mode='plain'` - Bypass Pydantic's validation entirely
- `mode='wrap'` - Full control with handler for Pydantic's validation

**Accessing Validation Data:**

```python
@field_validator('confirm_password')
@classmethod
def passwords_match(cls, v: str, info: ValidationInfo) -> str:
    # Access other validated fields
    password = info.data.get('password')
    # Access validation context
    if hasattr(info, 'context') and info.context:
        custom_value = info.context.get('custom_value')
```

### Model Validators

Use `@model_validator` for cross-field validation:

```python
from pydantic import BaseModel, model_validator
from typing_extensions import Self

class BookingCreate(BaseModel):
    start_date: str
    end_date: str

    @model_validator(mode='after')
    @classmethod
    def date_range_valid(cls, data: Self) -> Self:
        if data.start_date >= data.end_date:
            raise ValueError('start_date must be before end_date')
        return data
```

### Computed Fields

Use `@computed_field` for derived properties:

```python
from pydantic import BaseModel, computed_field

class Invoice(BaseModel):
    items: list[dict[str, float]]
    tax_rate: float

    @computed_field
    @property
    def subtotal(self) -> float:
        return sum(item['price'] * item['quantity'] for item in self.items)

    @computed_field
    @property
    def total(self) -> float:
        return self.subtotal * (1 + self.tax_rate)
```

### Best Practices

- **Use `Annotated` pattern** for reusable field configurations
- **Prefer after validators** over before validators when possible (type-safe)
- **Model validators** for multi-field validation logic
- **Field validators** for single-field transformations
- **Use type hints** in validator signatures for mypy support
- **Return validated value** - always return the value from validators

## Validators Standards

### Architecture

Validators are in the **business validation layer**, handling DB-level integrity checks that require data access:

```
app/
├── validators/
│   ├── __init__.py
│   ├── base.py
│   └── user_validator.py
└── services/
    └── user_service.py
```

### Pattern

Validators should be **classes** (not functions) for state management and reusability:

```python
class UserValidator:
    """
    Validates user-related business rules requiring DB access.
    """

    def __init__(self, user_repository: UserRepository | None = None):
        self.user_repository: UserRepository = user_repository or UserRepository()

    async def validate_email_unique(self, email: str) -> None:
        """Check if email is already registered."""
        existing = await self.user_repository.get_by_email(email)
        if existing:
            raise EmailAlreadyExistsError(email=email)

    async def validate_creation(self, email: str, username: str) -> None:
        """Validate all user creation rules."""
        await self.validate_email_unique(email)
        if len(username) < 3:
            raise ValidationError("Username too short", "username_min_length")
```

### Composing Validators

Small validators compose into larger service-level validators:

```python
class UserService:
    def __init__(self, user_validator: UserValidator):
        self.user_validator: UserValidator = user_validator

    async def create_user(self, data: UserCreateRequest) -> User:
        # Compose multiple small validators
        await self.user_validator.validate_email_unique(data.email)
        await self.user_validator.validate_creation(data.email, data.username)
        # Additional checks...
```

### Integration with Services

Validators are injected into services like repositories:

```python
class UserService:
    def __init__(
        self,
        db: AsyncSession,
        user_repository: UserRepository | None = None,
        user_validator: UserValidator | None = None
    ):
        self.db: AsyncSession = db
        self.user_repository: UserRepository = user_repository or UserRepository(db)
        self.user_validator: UserValidator = user_validator or UserValidator(self.user_repository)

    async def create(self, data: UserCreate) -> User:
        # Validate before creating
        await self.user_validator.validate_creation(email=data.email, username=data.username)
        # Create user
        return await self.user_repository.create(data=data)
```

### Best Practices

- **Repository injection**: Inject repositories optionally, instantiate if not provided
- **Atomic validators**: Each validator checks one specific rule
- **Composable**: Small validators compose into larger validation flows
- **Custom exceptions**: Use domain-specific exceptions, not generic ValueError
- **Clear error messages**: Provide actionable error messages for API consumers

## Repository Standards

### Core Principles

Repositories handle **data access only** - no business logic:

- Single CRUD operations: `get_by_id`, `get_all`, `create`, `update`, `patch`, `delete`
- No business validation (that's for validators)
- Use SQLAlchemy 2.0 `select()` syntax. `query()` is not allowed as it is deprecated.
- Return model objects or None, not dictionaries

### Best Practices

- **Type hints**: All methods must have return type annotations
- **Handle None**: Return `None` when not found rather than raising exceptions, which is the job of the validator
- **Flush vs commit**: Use `flush()` to persist but not commit : commits are handled through the database session
- **Use selectinload**: For eager loading relationships to prevent N+1 queries
- **No business logic**: Keep repositories pure data access
- **Pagination**: Implement limit/offset parameters for list operations

## Model Standards

### Modern SQLAlchemy 2.0 Syntax

Use `Mapped[Type]` and `mapped_column()` for type-safe models:

```python
from sqlalchemy import String, Integer
from sqlalchemy.orm import Mapped, mapped_column
from datetime import datetime

class User(Base):
    """User table model."""

    __tablename__ = 'users'

    id: Mapped[int] = mapped_column(primary_key=True)
    email: Mapped[str] = mapped_column(String(100), unique=True)
    username: Mapped[str] = mapped_column(String(50), nullable=False)
    created_at: Mapped[datetime] = mapped_column(default=datetime.utcnow)
    is_active: Mapped[bool] = mapped_column(default=True)
```

### Centralized Constraints

Use `__table_args__` for all table-level constraints and indexes:

```python
from sqlalchemy import CheckConstraint, Index, UniqueConstraint
from datetime import datetime

class User(Base):
    """User table with centralized constraints."""

    __tablename__ = 'users'

    id: Mapped[int] = mapped_column(primary_key=True)
    email: Mapped[str] = mapped_column(String(100))
    username: Mapped[str] = mapped_column(String(50), nullable=False)
    created_at: Mapped[datetime] = mapped_column(default=datetime.utcnow)
    is_active: Mapped[bool] = mapped_column(default=True)

    __table_args__ = (
        UniqueConstraint('email', name='uq_users_email'),
        UniqueConstraint('username', name='uq_users_username'),
        CheckConstraint(
            'length(username) > 0',
            name='chk_users_name_length'
        ),
        CheckConstraint(
            'length(email) > 5',
            name='chk_users_email_length'
        ),
        Index('idx_users_email', 'email'),
        Index('idx_users_created_at', 'created_at'),
    )
```

### Relationships

Define relationships clearly with loading strategies:

```python
from sqlalchemy import ForeignKey, Integer, String
from sqlalchemy.orm import Mapped, mapped_column, relationship

class User(Base):
    """User table."""

    __tablename__ = 'users'

    id: Mapped[int] = mapped_column(primary_key=True)
    email: Mapped[str] = mapped_column(String(100), unique=True)
    posts: Mapped[list['Post']] = relationship(
        'Post',
        back_populates='author',
        lazy='selectin',
        cascade='all, delete-orphan'
    )

class Post(Base):
    """Post table."""

    __tablename__ = 'posts'

    id: Mapped[int] = mapped_column(primary_key=True)
    title: Mapped[str] = mapped_column(String(200), nullable=False)
    content: Mapped[str] = mapped_column(String)
    user_id: Mapped[int] = mapped_column(ForeignKey('users.id'))
    user: Mapped[User] = relationship(
        'User',
        lazy='joined'
    )
```

### Indexes

Define single and composite indexes in `__table_args__`:

```python
__table_args__ = (
    Index('idx_user_email', 'email'),
    Index('idx_user_status_created', 'is_active', 'created_at'),
)
```

### Best Practices

- **Use `Mapped[Type]`**: Modern SQLAlchemy 2.0 syntax with type hints
- **Centralize constraints**: Use `__table_args__` for all table constraints and indexes
- **Naming conventions**: Use `name` parameter for constraints and indexes (ease migration process)
- **Composite constraints**: Use multi-column constraints where appropriate
- **Explicit types**: Always specify column types (String, Integer, etc.)
- **Relationship loading**: Choose appropriate lazy loading strategy (`lazy='selectin'`, `lazy='joined'`)
- **Cascade rules**: Ask the user for the cascades needed
- **No JSON in text columns**: Use `mapped_column(JSON)` not `mapped_column(String)` for JSON

## Services Standards

**Layer 1 - Syntax/Validation (DTOs)**: Use Pydantic for input validation : 422 errors

**Layer 2 - Business Validation**: Use `validators/` for checks requiring DB calls : specific custom exceptions

**Layer 3 - Business Logic**: Use `services/` for orchestration and transaction management

Services orchestrate repositories and validators to implement complete business flows:
