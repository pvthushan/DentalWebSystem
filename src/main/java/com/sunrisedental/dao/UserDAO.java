package com.sunrisedental.dao;

import com.sunrisedental.dto.*;
import java.util.List;

public interface UserDAO {
    User authenticate(String username, String password);
}

