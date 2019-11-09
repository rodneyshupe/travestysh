#!/usr/bin/env bash
#set -eu

# Default Constants
declare -gr DEFAULT_ARRAYSIZE=3000
declare -gr DEFAULT_PATTERN_LENGTH=9
declare -gr DEFAULT_PATTERN_LENGTH_MAX=15
declare -gr DEFAULT_PATTERN_LENGTH_MIN=3
declare -gr DEFAULT_OUTCHARS=2000
declare -gr DEFAULT_LINE_WIDTH=50

# Auguments
declare -g arg_buffer_size=${DEFAULT_ARRAYSIZE}
declare -g arg_pattern_length=${DEFAULT_PATTERN_LENGTH}
declare -g arg_max_pattern_length=${DEFAULT_PATTERN_LENGTH_MAX}
declare -g arg_out_chars=${DEFAULT_OUTCHARS}
declare -g arg_line_width=${DEFAULT_LINE_WIDTH}
declare -g arg_use_verse=false
declare -g arg_debug=false
declare -g arg_input_file="/dev/stdin"

function usage() {
  echo "USAGE"
}

function parse_arguments() {
  while [[ $# -gt 0 ]]; do
    case $1 in
      -h|--help)
        usage
        exit 1
        ;;
      -V|--version)
        exit 1
        ;;
      -p|--pattern-length)
        arg_pattern_length="$2"
        shift # past argument
        shift # past value
        ;;
      -b|--buffer-size)
        arg_buffer_size="$2"
        shift # past argument
        shift # past value
        ;;
      -o|--output-size)
        arg_out_chars="$2"
        shift # past argument
        shift # past value
        ;;
      -l|--line-width)
        arg_line_width="$2"
        shift
        shift
        ;;
      --verse)
        arg_use_verse=$(true)
        ;;
      -d|--debug)
        arg_debug=$(true)
        shift # past argument
        ;;
      *)    # unknown option
        arg_input_file=("$1") # save it in an array for later
        shift # past argument
        ;;
    esac
  done
}

function travesty() {

  # Global Constants
  local -r ARRAYSIZE_MAX=10000
  local -r ASCII_SPACE=32
  local -r ASCII_DEL=127

  # Input Arguments
  local buffer_size=${1}
  local pattern_length=${2}
  local out_chars=${3}
  local line_width=${4}
  local use_verse=$5
  local debug=$6
  local input_file=$7

  # Variable global to the travesty function
  local buffer=""
  local buffer_array=""
  local -A freq_array
  local -A start_skip
  local -a skip_array
  local pattern=""
  local char_count=0
  local near_end=$(false)

  # FreqArray is indexed by 93 probable ASCII characters, from ASCII_SPACE to ASCII_DEL.
  # Its elements are all set to zero.
  function clear_freq_array() {
    for ch in $(seq ${ASCII_SPACE} ${ASCII_DEL}); do
      freq_array["$ch"]=0
    done
  }

  # Reads input_file from disk into buffer_array, cleaning it up and reducing any run of
  # whitespace to a single space.  (If no inputfile is supplied stdin is used instead)
  # Once read it then copies to end of array a string of its opening characters as long
  # as the pattern_length, in effect wrapping the end to the beginning.
  function fill_array() {
    echo "Reading from: ${input_file}"
    buffer="$(cat "${input_file}")"
    local buffer_array_tmp="$(echo ${buffer//\\s\{2,\}\|\\n/ /})"
    buffer_array="${buffer_array_tmp:0:((${buffer_size}-((${pattern_length}+1)) ))} ${buffer_array_tmp:0:${pattern_length}}"

    echo "Characters read, plus wraparound = ${#buffer_array}"
  }

  #  User selects "order" of operation, an integer, n, in the range 1 .. 9. The input
  #  text will henceforth be scanned in n-sized chunks. The first n-1 characters of the
  #  input file are placed in the "Pattern" Array. The Pattern is written at the head of output.
  function first_pattern() {
    pattern="${buffer_array:0:${pattern_length}}"
    char_count=${pattern_length}
    near_end=false
    $use_verse && echo -n " " # Align first line
    echo -n "${pattern}"
  }

  # The i-th entry of skip_array contains the smallest index j < i such that
  # buffer_array[O] = buffer_array[i]. Thus skip_array links together all identical characters
  # in buffer_array.  start_skip contains the index of the first occurrence of each
  # character, These two arrays are used to skip the matching routine through the
  # text, stopping only at locations whose character matches the first character
  # in Pattern.
  function init_skip_array() {
    for ch in $(seq ${ASCII_SPACE} ${ASCII_DEL}); do
      start_skip["$ch"]=${#buffer_array}
    done
    for j in $(seq 1 ${#buffer_array}); do
      ch=${buffer_array:((j - 1)):1};
      skip_array[((j - 1))]=$start_skip["$ch"];
      start_skip["$ch"]=j;
    done
}

  # Checks buffer_array for strings that match Pattern; for each match found, notes
  # following character and increments its count in FreqArray. Position for first
  # trial comes from StartSkip; thereafter positions are taken from SkipArray.
  # Thus no sequence is checked unless its first character is already known to
  # match first character of Pattern.
  function match_pattern() {
    true
  }

  # It is chosen at Random from characters accumulated in FreqArray during
  # last scan of input.
  function get_next_char() {
    true
  }

  # The next character is written.  Output lines will
  # average line_width characters in length. If "Verse" option has been selected,
  # a new line will commence after any word that ends with "'"in input file.
  # Thereafter lines will be indented until the line_width-character average has
  # been made up.
  function write_character() {
    next_char=$1

    char_count=$(($char_count+1))
  }

  # This removes the first character of the Pattern and appends the character
  # just printed. FreqArray is zeroed in preparation for a new scan.
  function new_pattern() {
    next_char=$1

    pattern="${pattern:1..((${pattern_length}-1))}${next_char}"
    clear_freq_array
  }

  function output_debug_info {
    show_buffer=$1
    show_buffer_array=$2

    echo -n "buffer_size=${buffer_size} ";
    echo -n "pattern_length=${pattern_length} "
    echo -n "out_chars=${out_chars} "
    echo -n "input_file=${input_file} "
    echo -n "buffer size=${#buffer} "
    echo -n "buffer_array Size=${#buffer_array} "
    echo ""
    echo ""
    if ${show_buffer} ; then
      echo "Buffer Data:"
      echo ${buffer}
      echo ""
    fi
    if ${show_buffer_array} ; then
      echo "buffer_array:"
      echo "${buffer_array}"
      echo ""
    fi
  }

  function execute {
    clear_freq_array
    fill_array

    if ${debug} ; then
      output_debug_info false false
    fi

    first_pattern
    init_skip_array

    next_char=' '
    while [ $char_count -gt $out_chars ] || [[ "$next_char" != " " ]]; do
        match_pattern
        next_char=$(get_next_char)
        write_character $next_char
        new_pattern $next_char
    done

    echo ""
    echo ""
    echo "Output: ${char_count} characters."
  }

  execute
}

parse_arguments "$@"
travesty "${arg_buffer_size}" \
      "${arg_pattern_length}" \
      "${arg_out_chars}" \
      "${arg_line_width}" \
      "${arg_use_verse}" \
      "${arg_debug}" \
      "${arg_input_file}"
