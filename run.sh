#!/bin/bash

# Black Box Legacy Reimbursement System
# Implementation using micro-tuned hybrid model

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Input parameters
TRIP_DURATION_DAYS="$1"
MILES_TRAVELED="$2"
TOTAL_RECEIPTS_AMOUNT="$3"

# Validate inputs
if [[ -z "$TRIP_DURATION_DAYS" || -z "$MILES_TRAVELED" || -z "$TOTAL_RECEIPTS_AMOUNT" ]]; then
    echo "Usage: $0 <trip_duration_days> <miles_traveled> <total_receipts_amount>" >&2
    exit 1
fi

# Run the Python solution directly with just the calculation
python3 -c "
import sys

def calculate_reimbursement(trip_duration_days, miles_traveled, total_receipts_amount):
    days = int(trip_duration_days)
    miles = float(miles_traveled)
    receipts = float(total_receipts_amount)
    
    # Simple linear base model
    base_amount = 61 * days + 0.59 * miles + 0.44 * receipts + 5
    
    # Apply micro-tuned business rule adjustments
    adjustments = 0
    
    # Short trip premium
    if days == 1:
        adjustments += base_amount * 0.08
    elif days == 2:
        adjustments += base_amount * 0.04
    
    # 5-day trip bonus
    if days == 5:
        adjustments += base_amount * 0.04
    elif days == 6:
        adjustments += base_amount * 0.02
    
    # Micro-tuned efficiency bonus
    if days > 0:
        miles_per_day = miles / days
        if 180 <= miles_per_day <= 220:
            adjustments += base_amount * 0.04
        elif 150 <= miles_per_day < 180 or 220 < miles_per_day <= 280:
            adjustments += base_amount * 0.015
    
    # Tiered mileage adjustment
    if miles > 100:
        excess_miles = miles - 100
        adjustments -= excess_miles * 0.59 * 0.08
    
    # Receipt adjustments
    if 600 <= receipts <= 800:
        adjustments += base_amount * 0.03
    if days > 1 and receipts < 50:
        adjustments -= base_amount * 0.02
    if receipts > 1500:
        excess = receipts - 1500
        adjustments -= excess * 0.44 * 0.35
    
    # Interaction bonuses
    if days > 0:
        miles_per_day = miles / days
        receipts_per_day = receipts / days
        if days == 5 and miles_per_day >= 180 and receipts_per_day < 100:
            adjustments += base_amount * 0.05
        if days >= 8 and receipts_per_day > 150:
            adjustments -= base_amount * 0.05
    
    final_amount = base_amount + adjustments
    return max(final_amount, 0)

if len(sys.argv) != 4:
    print('Usage: calculate_reimbursement <days> <miles> <receipts>', file=sys.stderr)
    sys.exit(1)

result = calculate_reimbursement(sys.argv[1], sys.argv[2], sys.argv[3])
print(f'{result:.2f}')
" "$TRIP_DURATION_DAYS" "$MILES_TRAVELED" "$TOTAL_RECEIPTS_AMOUNT" 2>/dev/null || {
    # Fallback: inline calculation if solution.py fails
    python3 -c "
import sys

def calculate_reimbursement(trip_duration_days, miles_traveled, total_receipts_amount):
    days = int(trip_duration_days)
    miles = float(miles_traveled)
    receipts = float(total_receipts_amount)
    
    # Simple linear base model
    base_amount = 61 * days + 0.59 * miles + 0.44 * receipts + 5
    
    # Apply micro-tuned business rule adjustments
    adjustments = 0
    
    # Short trip premium
    if days == 1:
        adjustments += base_amount * 0.08
    elif days == 2:
        adjustments += base_amount * 0.04
    
    # 5-day trip bonus
    if days == 5:
        adjustments += base_amount * 0.04
    elif days == 6:
        adjustments += base_amount * 0.02
    
    # Micro-tuned efficiency bonus
    if days > 0:
        miles_per_day = miles / days
        if 180 <= miles_per_day <= 220:
            adjustments += base_amount * 0.04
        elif 150 <= miles_per_day < 180 or 220 < miles_per_day <= 280:
            adjustments += base_amount * 0.015
    
    # Tiered mileage adjustment
    if miles > 100:
        excess_miles = miles - 100
        adjustments -= excess_miles * 0.59 * 0.08
    
    # Receipt adjustments
    if 600 <= receipts <= 800:
        adjustments += base_amount * 0.03
    if days > 1 and receipts < 50:
        adjustments -= base_amount * 0.02
    if receipts > 1500:
        excess = receipts - 1500
        adjustments -= excess * 0.44 * 0.35
    
    # Interaction bonuses
    if days > 0:
        miles_per_day = miles / days
        receipts_per_day = receipts / days
        if days == 5 and miles_per_day >= 180 and receipts_per_day < 100:
            adjustments += base_amount * 0.05
        if days >= 8 and receipts_per_day > 150:
            adjustments -= base_amount * 0.05
    
    final_amount = base_amount + adjustments
    return max(final_amount, 0)

if len(sys.argv) != 4:
    print('Usage: calculate_reimbursement <days> <miles> <receipts>', file=sys.stderr)
    sys.exit(1)

result = calculate_reimbursement(sys.argv[1], sys.argv[2], sys.argv[3])
print(f'{result:.2f}')
" "$TRIP_DURATION_DAYS" "$MILES_TRAVELED" "$TOTAL_RECEIPTS_AMOUNT"
}