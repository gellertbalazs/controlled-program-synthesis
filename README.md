# Controlled Program Synthesis

## Describe the program. Get checked pseudocode.

Controlled Program Synthesis (CPS) explores a direct way to build software:
write a bounded specification of **what the program must do**, let the system
construct a program shape, check that shape independently, and present the
result as readable, language-neutral pseudocode.

> **Vision demo:** this README demonstrates the intended experience. The
> repository is a research prototype, and not every example below is available
> end to end yet.

```text
+----------------------+      +----------------------+      +----------------------+
| SOFTWARE SPEC        | ---> | SYNTHESIZE + CHECK   | ---> | PSEUDOCODE           |
| what must be true    |      | justify every step   |      | how it can be done   |
+----------------------+      +----------------------+      +----------------------+
```

The goal is not to hide software behind a clever prompt. The goal is to make
the requested behavior, the proposed algorithm, and the reason it is accepted
separate and inspectable.

## A complete interaction in 15 seconds

You write a small controlled specification:

```text
software BasketTotal

input prices as a sequence of Money
output total as Money

require total equals the sum of prices from left to right
when prices is empty use 0
```

CPS presents the checked program structure as pseudocode:

```text
FUNCTION BasketTotal(prices)
    total <- 0

    FOR EACH price IN prices DO
        total <- total + price
    END FOR

    RETURN total
END FUNCTION
```

The specification says what result is required. The pseudocode makes the
chosen algorithm visible. The empty-input behavior is explicit rather than
guessed.

## Start small: structure becomes visible

The smallest examples reveal the central idea without domain noise.

### One value

```text
SPECIFICATION
    reduce the sequence [alpha] from the left using combine

PSEUDOCODE
    alpha
```

There is nothing to combine, so the only value is the result.

### Two values

```text
SPECIFICATION
    reduce the sequence [alpha, beta] from the left using combine

PSEUDOCODE
    combine(alpha, beta)
```

### Three values

```text
SPECIFICATION
    reduce the sequence [alpha, beta, gamma] from the left using combine

PSEUDOCODE
    combine(combine(alpha, beta), gamma)
```

The grouping is part of the program, not a formatting accident:

```text
              combine
             /       \
        combine      gamma
        /     \
    alpha     beta
```

Left grouping is different from `combine(alpha, combine(beta, gamma))`. CPS
must preserve the requested structure exactly; it may not silently balance,
reorder, parallelize, or reinterpret the operation.

## Example gallery

The examples below use a compact controlled-English style for readability.
They illustrate the intended interaction and output format, not a promise that
every word shown is already accepted syntax.

### 1. Return a value unchanged

You specify:

```text
software KeepValue

input value as Item
output result as Item

require result equals value
```

CPS shows:

```text
FUNCTION KeepValue(value)
    RETURN value
END FUNCTION
```

### 2. Transform every item

You specify:

```text
software NormalizeNames

input names as a sequence of Text
output normalized_names as a sequence of Text

require each output item equals normalize of the corresponding input item
preserve input order
```

CPS shows:

```text
FUNCTION NormalizeNames(names)
    normalized_names <- empty sequence

    FOR EACH name IN names DO
        APPEND normalize(name) TO normalized_names
    END FOR

    RETURN normalized_names
END FUNCTION
```

### 3. Keep only matching items

You specify:

```text
software AvailableProducts

input products as a sequence of Product
output available_products as a sequence of Product

require output contains exactly the products where product.available is true
preserve input order
```

CPS shows:

```text
FUNCTION AvailableProducts(products)
    available_products <- empty sequence

    FOR EACH product IN products DO
        IF product.available = true THEN
            APPEND product TO available_products
        END IF
    END FOR

    RETURN available_products
END FUNCTION
```

### 4. Filter, transform, and total

You specify:

```text
software ApprovedRevenue

input orders as a sequence of Order
output revenue as Money

use only orders where order.status equals approved
for each used order compute order.amount minus order.refund
replace a negative computed amount with 0
require revenue equals the sum of the computed amounts
when no order is used return 0
```

CPS shows:

```text
FUNCTION ApprovedRevenue(orders)
    revenue <- 0

    FOR EACH order IN orders DO
        IF order.status = "approved" THEN
            net_amount <- order.amount - order.refund

            IF net_amount < 0 THEN
                net_amount <- 0
            END IF

            revenue <- revenue + net_amount
        END IF
    END FOR

    RETURN revenue
END FUNCTION
```

### 5. Find the first match

You specify:

```text
software FirstOverdueAccount

input accounts as a sequence of Account
output result as Account or none

require result equals the first account where account.overdue is true
preserve input order
when no account matches return none
```

CPS shows:

```text
FUNCTION FirstOverdueAccount(accounts)
    FOR EACH account IN accounts DO
        IF account.overdue = true THEN
            RETURN account
        END IF
    END FOR

    RETURN none
END FUNCTION
```

### 6. Make a boundary decision

You specify:

```text
software ShippingFee

input basket_total as Money
output fee as Money

when basket_total is at least 50 require fee equals 0
otherwise require fee equals 5
```

CPS shows:

```text
FUNCTION ShippingFee(basket_total)
    IF basket_total >= 50 THEN
        RETURN 0
    END IF

    RETURN 5
END FUNCTION
```

The exact boundary is visible: a total of `50` receives free shipping.

### 7. Choose deterministically

You specify:

```text
software BestOffer

input offers as a non-empty sequence of Offer
output best as Offer

prefer the offer with the lowest price
when prices are equal prefer the lowest supplier_id
```

CPS shows:

```text
FUNCTION BestOffer(offers)
    best <- first item of offers

    FOR EACH offer IN remaining items of offers DO
        lower_price <- offer.price < best.price
        same_price <- offer.price = best.price
        lower_id <- offer.supplier_id < best.supplier_id

        IF lower_price OR (same_price AND lower_id) THEN
            best <- offer
        END IF
    END FOR

    RETURN best
END FUNCTION
```

The tie-break rule prevents two equally plausible outputs from being chosen
arbitrarily.

### 8. Group and summarize

You specify:

```text
software SpendByCustomer

input orders as a sequence of Order
output totals as a map from CustomerId to Money

for every customer_id require its total equals the sum of order.amount
for orders having that customer_id
when a customer_id is first seen start its total at 0
```

CPS shows:

```text
FUNCTION SpendByCustomer(orders)
    totals <- empty map

    FOR EACH order IN orders DO
        customer_id <- order.customer_id

        IF totals does not contain customer_id THEN
            totals[customer_id] <- 0
        END IF

        totals[customer_id] <- totals[customer_id] + order.amount
    END FOR

    RETURN totals
END FUNCTION
```

### 9. Validate with explicit priority

You specify:

```text
software SignupDecision

input email as Text
input age as Integer
output decision as accepted or rejected with reason

reject missing_email when email is empty
otherwise reject invalid_email when email is not valid
otherwise reject age_requirement when age is less than 18
otherwise accept
```

CPS shows:

```text
FUNCTION SignupDecision(email, age)
    IF email is empty THEN
        RETURN rejected("missing_email")
    END IF

    IF email is not valid THEN
        RETURN rejected("invalid_email")
    END IF

    IF age < 18 THEN
        RETURN rejected("age_requirement")
    END IF

    RETURN accepted
END FUNCTION
```

The order of the rules is observable. An empty and invalid email reports
`missing_email` because that requirement has higher priority.

### 10. Define a state transition

You specify:

```text
software AdvanceOrder

input state as pending, paid, or shipped
input event as payment_confirmed or shipment_confirmed
output next_state as pending, paid, shipped, or rejected with reason

when state is pending and event is payment_confirmed return paid
when state is paid and event is shipment_confirmed return shipped
otherwise reject invalid_transition
```

CPS shows:

```text
FUNCTION AdvanceOrder(state, event)
    IF state = "pending" AND event = "payment_confirmed" THEN
        RETURN "paid"
    END IF

    IF state = "paid" AND event = "shipment_confirmed" THEN
        RETURN "shipped"
    END IF

    RETURN rejected("invalid_transition")
END FUNCTION
```

### 11. Stop honestly at a declared bound

You specify:

```text
software LocateMatchingRecord

input records as a sequence of Record
output result as Record, none, or unknown with reason

inspect records in input order
inspect at most 100 records
return the first record where matches(record) is true
return none only when every record was inspected and no record matched
otherwise return unknown inspection_limit_reached
```

CPS shows:

```text
FUNCTION LocateMatchingRecord(records)
    inspected <- 0

    FOR EACH record IN records DO
        IF inspected = 100 THEN
            RETURN unknown("inspection_limit_reached")
        END IF

        inspected <- inspected + 1

        IF matches(record) THEN
            RETURN record
        END IF
    END FOR

    RETURN none
END FUNCTION
```

`none` and `unknown` mean different things. `none` says the complete bounded
input was inspected. `unknown` says the system reached its limit before it
could justify that conclusion.

## What happens between the two text blocks?

The synthesizer is allowed to propose. It is not allowed to approve its own
work.

```text
                          PROPOSAL SIDE                 CHECKING SIDE

  specification ---> parse ---> propose program ---> independent check
                                                           |       |
                                                     not accepted  accepted
                                                           |       |
                                                     explanation  render
                                                                   |
                                                                   v
                                                              pseudocode
```

In the intended system:

- the specification is converted into a structured, typed description;
- a candidate program and its justification are proposed;
- a separate checker reconstructs and validates the program structure;
- every required premise and obligation must be available and accepted;
- the renderer formats only the checked structure and adds no new meaning.

This separation matters whether a proposal came from a fixed rule, a search
procedure, a solver, a human, or an AI model. Origin is not proof.

## Sometimes the correct demonstration is no pseudocode

CPS is designed to explain why it cannot justify an output instead of filling
gaps with a guess.

```text
AMBIGUOUS
    Two valid programs remain because no tie-break rule was specified.

UNSUPPORTED
    The requested behavior is outside the controlled fragment.

UNKNOWN
    A required premise or proof obligation is missing.

RESOURCE LIMIT
    The next required observation lies beyond an explicit bound.
```

No non-accepting result is disguised as a successful program.

## What makes the pseudocode useful?

- **Readable:** the output exposes loops, branches, grouping, boundaries, and
  return paths without target-language ceremony.
- **Deterministic:** the same accepted program structure has one stable
  presentation.
- **Language-neutral:** the checked structure can be reviewed before anyone
  chooses an implementation language.
- **Content-preserving:** formatting cannot invent a condition, reorder an
  operation, repair an omission, or choose between meanings.
- **Non-executing:** the demonstration prints a program description; it does
  not run user-supplied behavior.

## The promise, in one picture

```text
  YOU CONTROL                 CPS MUST EXPLAIN              YOU REVIEW

  inputs                      chosen structure              readable steps
  outputs        -------->    assumptions        -------->  edge cases
  rules                       obligations                   stop conditions
  bounds                      acceptance result             exact grouping
```

A colleague reading the pseudocode should be able to answer:

1. What goes in and what comes out?
2. Which cases are accepted, rejected, or still unknown?
3. In what order are values inspected and operations applied?
4. What happens at empty inputs, ties, boundaries, and limits?
5. Which details came from the specification rather than from a guess?

That is the intended “wow”: not merely code-shaped text, but a visible bridge
from a precise request to an inspectable program.

## Current scope

The repository currently develops small, bounded parts of this idea: controlled
input, structured specifications, source-relative evidence, independent
checking, and explicit outcomes. The gallery above is the product direction,
not a claim that arbitrary natural language or every illustrated program is
already supported.

## Explore the design

- [Architecture overview](docs/architecture/README.md)
- [Design decisions](docs/decisions/README.md)
- [Evaluation principles](docs/evaluation/README.md)
- [Reference orientation](docs/reference/README.md)
- [Source component map](src/README.md)
- [Controlled-language boundary](src/cnl/README.md)
- [Verification boundary](src/verification/README.md)
- [Test organization](tests/README.md)

## License

No license or copyright grant has been added. Unless and until that changes,
do not assume permission to copy, modify, or redistribute the repository.
