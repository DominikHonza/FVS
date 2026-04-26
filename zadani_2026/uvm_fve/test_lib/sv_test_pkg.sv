package sv_timer_t_test_pkg;
    import uvm_pkg::*;
    import sv_param_pkg::*;
    import sv_timer_t_agent_pkg::*;
    import sv_timer_t_gm_pkg::*;
    import sv_timer_t_env_pkg::*;
    import registers_pkg::*;

    `include "uvm_macros.svh"
    `include "test_base.svh"
    `include "test.svh"
    `include "random_t_test.svh"
    `include "autorestart_t_test.svh"
    `include "oneshot_t_test.svh"
    `include "disabled_t_test.svh"
    `include "continuous_t_test.svh"
    `include "continous_t_test.svh"
    `include "mode_transition_t_test.svh"
    `include "full_access_t_test.svh"
    `include "reset_stress_t_test.svh"
    `include "edge_cases_t_test.svh"
    `include "addr_bus_branch_cover_t_test.svh"
    `include "muj_prvni_t_test.svh"
    `include "full_cov_t_test.svh"
    `include "formal_t_test.svh"
    `include "reg_t_test.svh"

endpackage: sv_timer_t_test_pkg
