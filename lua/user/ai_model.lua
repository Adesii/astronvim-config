-- Model selection configuration
local models = {
  qwen35_9b = "Qwen3.5-9B-GGUF",
  bonsai_8b = "prism-ml/Bonsai-8B-gguf:8B",
  gemma_4_26b_a4b = "unsloth/gemma-4-26B-A4B-it-GGUF:Q4_K_XL",
  gemma_4_26b_a3b = "unsloth/gemma-4-26B-A4B-it-GGUF:Q3_K_M",
  qwen3_coder_30b = "Qwen3-Coder-30B-A3B-GGUF",
}

-- Current model selection (change this to switch models)
local current_model = "qwen3_coder_30b"

-- Function to get the selected model
local function get_model() return models[current_model] end

-- Example usage:
-- print(get_model())

return get_model()
