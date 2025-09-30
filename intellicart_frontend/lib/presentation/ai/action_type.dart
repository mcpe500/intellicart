/// Enum representing the different types of actions that can be performed
/// through AI interaction.
enum ActionType {
  /// Add an item to the cart
  addToCart,

  /// Remove an item from the cart
  removeFromCart,

  /// Search for products
  search,

  /// Create a new product
  createProduct,

  /// Update an existing product
  updateProduct,

  /// Delete a product
  deleteProduct,

  /// View the cart
  viewCart,

  /// Checkout the cart
  checkout,
}