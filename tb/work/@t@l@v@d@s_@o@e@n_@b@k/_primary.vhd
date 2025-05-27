library verilog;
use verilog.vl_types.all;
entity TLVDS_OEN_BK is
    generic(
        OEN_BANK        : string  := "0"
    );
    port(
        OEN             : in     vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of OEN_BANK : constant is 1;
end TLVDS_OEN_BK;
