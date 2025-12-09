/*
 * SPDX-License-Identifier: LicenseRef-AGPL-3.0-only-OpenSSL
 *
 * Stub implementations for PS address/port helpers when not available.
 */

#include <chiaki/session.h>
#include <chiaki/ctrl.h>
#include <stdint.h>

const char *chiaki_get_ps_selected_addr(ChiakiSession *session)
{
    (void)session;
    return NULL; // stub: no selected address
}

uint16_t chiaki_get_ps_ctrl_port(ChiakiSession *session)
{
    (void)session;
    return 9307; // stub: default control port
}
