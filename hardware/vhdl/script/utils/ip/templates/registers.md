# {{name}} Register Map

{{description}}

Register width: 32 bits<br>
Address width: {{addr_width}} bits

{% for reg in map %}
---
### {{reg.name|upper}}
{{reg.description}}

| Address: `0x{{reg.offset|hex}}` | *{{reg.access|upper}}* |
| :--- | ---: |
{% for field in reg.fields %}
{% if field.width > 1 %}
| *{{field.name|upper}}*<br>{{field.description}} | Bits: `[{{field.width + field.offset - 1}}:{{field.offset}}]`<br>Reset: `0x{{field.reset|hex}}` |
{% else %}
| *{{field.name|upper}}*<br>{{field.description}} | Bits: `[{{field.offset}}]`<br>Reset: `0x{{field.reset|hex}}` |
{% endif %}
{% endfor %}

{% endfor %}

---
*Copyright (C) 2017-2021 Michael Wurm*
