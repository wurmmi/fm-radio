/*
 * Copyright (C) 2017-2021 Michael Wurm
 * Author: Super Easy Register Scripting Engine (SERSE)
 *
/* {{name}} register map */

#ifndef {{name|pretty|upper}}_H
#define {{name|pretty|upper}}_H

#include <stdint.h>

/* {{name}} AXI-Lite base address */
#define {{name|pretty|upper}}_BASE (({{name|pretty}}_t *)0x40300000)

/* {{name}} register structure */
typedef struct {
{% for reg in original %}
{% if reg.type == "ARRAY" or reg.type == "TRK_ARRAY" %}
{% if reg.access == "READ_ONLY" %}
const volatile u32 {{reg.name|pretty|replace("[n]", "")|upper}}[{{reg.size}}];
{% else %}
        volatile u32 {{reg.name|pretty|replace("[n]", "")|upper}}[{{reg.size}}];
{% endif %}
{% else %}
{% if reg.access == "READ_ONLY" %}
  const volatile u32 {{reg.name|pretty|upper}};
{% else %}
        volatile u32 {{reg.name|pretty|upper}};
{% endif %}
{% endif %}
{% endfor %}
} {{name|pretty}}_t;

{% for reg in original %}
/* Register: {{reg.full|upper}} */
{% for field in reg.fields %}
#define {{reg.full|replace("[n]", "")|upper}}_{{field.name|upper}}_Pos ({{field.offset}}U)
#define {{reg.full|replace("[n]", "")|upper}}_{{field.name|upper}}_Len ({{field.width}}U)
#define {{reg.full|replace("[n]", "")|upper}}_{{field.name|upper}}_Rst (0x{{field.reset|hex}}U)
#define {{reg.full|replace("[n]", "")|upper}}_{{field.name|upper}}_Msk \
    (0x{{field.width|mask}}U << {{reg.full|replace("[n]", "")|upper}}_{{field.name|replace("[n]", "")|upper}}_Pos)
{% if reg.access != "WRITE_ONLY" %}
#define GET_{{reg.full|replace("[n]", "")|upper}}_{{field.name|upper}}(REG) \
    (((REG) & {{reg.full|replace("[n]", "")|upper}}_{{field.name|upper}}_Msk) >> {{reg.full|replace("[n]", "")|upper}}_{{field.name|upper}}_Pos)
{% endif %}
{% if reg.access != "READ_ONLY" %}
#define SET_{{reg.full|replace("[n]", "")|upper}}_{{field.name|upper}}(REG, VAL) \
    (((REG) & ~{{reg.full|replace("[n]", "")|upper}}_{{field.name|upper}}_Msk) | ((VAL) << {{reg.full|replace("[n]", "")|upper}}_{{field.name|upper}}_Pos))
{% endif %}

{% endfor %}
{% endfor %}
#endif /* {{name|pretty|upper}}_H */

