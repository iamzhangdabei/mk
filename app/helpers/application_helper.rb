module ApplicationHelper
 def body_class_names
    today = Date.today
    [controller.controller_name, "#{controller.controller_name}-#{controller.action_name}",
     logged_in? ? 'logged_in' : 'not_logged_in',
    "y#{today.year}", "m#{today.month}", "d#{today.day}"
    ]
  end
end
