#!/bin/bash
FORMULA="$1"

if [[ -z "$FORMULA" ]]; then
    echo "Usage: $0 <formula>"
    exit -1
fi

echo "Building $FORMULA at" $(date)

brew=homebrew/bin/brew
if [[ ! -f $brew ]]; then
	git clone https://github.com/Homebrew/homebrew.git homebrew
	$brew tap staticfloat/julia
	$brew tap staticfloat/juliadeps
fi

# Update our caches!
$brew update

# Remove everything first, so we always start clean
$brew rm $($brew list) 2>/dev/null

# Install dependencies first as bottles when possible
deps=$($brew deps -n $1)
for dep in $deps; do
	base=$(basename $dep)
	# Check to see if this depdency can be installed via bottle
	if [[ ! -z $($brew info $dep | grep bottled) ]]; then
		# If so, install it!
		$brew install -v $dep
	else
		# Otherwise, build it with --build-bottle
		$brew install -v --build-bottle $dep
	fi
done

# Then, finally, build the bottle!
$brew install -v --build-bottle $FORMULA

# Bottle it!
$brew bottle -v $FORMULA