UTILS_VISIONA = "1.1.0"

require_relative "utils/procedures"
require_relative "utils/test_procedures"
require_relative "utils/ccsds"
require_relative "utils/checksum"
require_relative "utils/conversions"
require_relative "utils/verifications"
require_relative "utils/operations"
require_relative "utils/os"

module Utils_visiona

  DEBUG = 0

  # PROCEDURES
  ## Targets
  module_function :target_hk_enabled?
  module_function :enable_TO
  module_function :send_validated_cmd

  ## Tables
  module_function :lva_table
  module_function :read_table_item

  ## Transfer
  module_function :downlinkTransfer
  module_function :uplinkTransfer
  module_function :calculateWaitTime

  ## Misc
  module_function :PDUS?
  module_function :appendFile

  # TEST PROCEDURES
  module_function :skip_test
  module_function :print_current_test_info
  module_function :miss_pdus
  module_function :createMainTestDir
  module_function :createRandomFile
  module_function :printFullHash

  # CCSDS
  module_function :removeCCSDSHeader

  # CHECKSUM
  module_function :calculateFileChecksum

  # CONVERSIONS
  module_function :strToDecArray
  module_function :getDecValueFromHexa
  module_function :decArrayToHexaStr
  module_function :hexaStrToDecArray
  module_function :IDtoStrArray
  module_function :getDecimalFromByteArray

  # VERIFICATIONS
  module_function :hasSymbol?
  module_function :checkByteArray
  module_function :verifyLength
  module_function :compareValues
  module_function :verifyInput

  # OPERATIONS
  module_function :getBits
  module_function :completeBytes

  # OS
  module_function :writeFile
  module_function :OS_print
end