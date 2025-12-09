/*
 * SPDX-License-Identifier: LicenseRef-AGPL-3.0-only-OpenSSL
 *
 * Stub implementations for PS address/port helpers when not available.
 */

#include <chiaki/remote/holepunch.h>
#include <stdint.h>

// Stub: fill ps_ip with an empty string
void chiaki_get_ps_selected_addr(ChiakiHolepunchSession session, char *ps_ip)
{
    (void)session;
    if (ps_ip)
        ps_ip[0] = '\0';
}

// Stub: return a safe default port
uint16_t chiaki_get_ps_ctrl_port(ChiakiHolepunchSession session)
{
    (void)session;
    return 9307; // default control port
}
