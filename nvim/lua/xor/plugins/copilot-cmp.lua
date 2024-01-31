return {
	'zbirenbaum/copilot-cmp',
	requires = 'copilot',
	config = function()
	  local cmp = require('cmp')
	  local copilot = require('copilot')
	  local copilot_cmp = require('copilot_cmp')
  
	  copilot_cmp.setup()
  
	  cmp.setup({
		sources = {
		  { name = 'copilot' },
		},
		completion = {
		  keyword_length = 2,
		},
		snippet = {
		  expand = function(args)
			copilot.snippet(args.body)
		  end,
		},
	  })
  
	  -- Check if copilot.lsp is available before calling setup
	  if copilot.lsp then
		copilot.lsp.setup()
	  else
		-- You may want to print a warning or handle this case appropriately
		print("copilot.lsp is not available.")
	  end
	end,
  }
  