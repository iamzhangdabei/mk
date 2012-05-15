module ApplicationHelper
 def body_class_names
    today = Date.today
    [controller.controller_name, "#{controller.controller_name}-#{controller.action_name}",
    "y#{today.year}", "m#{today.month}", "d#{today.day}"
    ]
  end
end
